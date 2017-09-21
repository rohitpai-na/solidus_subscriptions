# The subscription class is responsable for grouping together the
# information required for the system to place a subscriptions order on
# behalf of a specific user.
module SolidusSubscriptions
  class Subscription < ActiveRecord::Base

    PROCESSING_STATES = [:pending, :failed, :success]

    belongs_to :line_item, 
      class_name: "SolidusSubscriptions::LineItem", 
      inverse_of: :subscription

    belongs_to :subscription_preset,
      class_name: "SolidusSubscriptions::SubscriptionPreset",
      inverse_of: :subscriptions

    has_one :order, through: :line_item

    has_one :user, through: :order

    has_many :installments, class_name: 'SolidusSubscriptions::Installment'

    has_many :state_changes, class_name: "Spree::StateChange", as: :stateful

    belongs_to :supplier,
      class_name: 'Spree::Supplier',
      inverse_of: :subscriptions

    # validates :skip_count, :successive_skip_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :number, presence: true, uniqueness: { allow_blank: true }

    # accepts_nested_attributes_for :shipping_address
    # accepts_nested_attributes_for :line_item, allow_destroy: true

    delegate :quantity, :variant, to: :line_item

    delegate :delivery_interval, :delivery_interval_units, :delivery_interval_length,
      :bill_interval, :bill_interval_units, :bill_interval_length,
      :contract_interval, :contract_interval_units, :contract_interval_length,
      :interval, :interval_units, :interval_length, :delivery_category_continuous?,
      :unit_price, :unit_price_interval_units, :unit_price_interval_length,
      to: :subscription_preset

    make_permalink field: :number, length: 11, prefix: 'O'

    # Find all subscriptions that are "actionable"; that is, ones that have an
    # actionable_date in the past and are not invalid or canceled.
    scope :actionable, (lambda do
      where("#{table_name}.actionable_date <= ?", Time.zone.now).
        where.not(state: ["canceled", "inactive"])
    end)

    # Find subscriptions based on their processing state. This state is not a
    # model attrubute.
    #
    # @param state [Symbol] One of :pending, :success, or failed
    #
    # pending: New subscriptions, never been processed
    # failed: Subscriptions which failed to be processed on the last attempt
    # success: Subscriptions which were successfully processed on the last attempt
    scope :in_processing_state, (lambda do |state|
      case state.to_sym
      when :success
        fulfilled.joins(:installments)
      when :failed
        fulfilled_ids = fulfilled.pluck(:id)
        where.not(id: fulfilled_ids)
      when :pending
        includes(:installments).where(solidus_subscriptions_installments: { id: nil })
      else
        raise ArgumentError.new("state must be one of: :success, :failed, :pending")
      end
    end)

    scope :fulfilled, (lambda do
      unfulfilled_ids = unfulfilled.pluck(:id)
      where.not(id: unfulfilled_ids)
    end)

    scope :unfulfilled, (lambda do
      joins(:installments).merge(Installment.unfulfilled)
    end)

    def self.ransackable_scopes(_auth_object = nil)
      [:in_processing_state]
    end

    def self.processing_states
      PROCESSING_STATES
    end

    # The subscription state determines the behaviours around when it is
    # processed. Here is a brief description of the states and how they affect
    # the subscription.
    #
    # [pending] Default state when created.
    # [active] Shipment has been delivered/installed. Subscription can be processed
    # [canceled] The user has ended their subscription. Subscription will not
    #   be processed.
    # [pending_cancellation] The user has ended their subscription, but the
    #   conditions for canceling the subscription have not been met. Subscription
    #   will continue to be processed until the subscription is canceled and
    #   the conditions are met.
    # [inactive] The number of installments has been fulfilled. The subscription
    #   will no longer be processed
    state_machine :state, initial: :pending do
      event :cancel do
        transition [:pending, :active, :pending_cancellation] => :canceled,
          if: ->(subscription) { subscription.can_be_canceled? }

        transition active: :pending_cancellation
      end
      after_transition to: :canceled, do: [:advance_actionable_date, :after_cancel]

      event :deactivate do
        transition active: :inactive,
          if: ->(subscription) { subscription.can_be_deactivated? }
      end
      after_transition to: :inactive, do: :after_deactivate

      event :activate do
        transition any - [:active] => :active,
          if: ->(subscription) { subscription.can_be_activated? }
      end
      after_transition to: :active, do: [:advance_actionable_date, :after_activate]

      after_transition do |subscription, transition|
        subscription.state_changes.create!(
          previous_state: transition.from,
          next_state:     transition.to,
          name:           'subscription'
        )
      end
    end

    # This method determines if a subscription may be canceled. Canceled
    # subcriptions will not be processed. By default subscriptions may always be
    # canceled. If this method is overriden to return false, the subscription
    # will be moved to the :pending_cancellation state until it is canceled
    # again and this condition is true.
    #
    # USE CASE: Subscriptions can only be canceled more than 10 days before they
    # are processed. Override this method to be:
    #
    # def can_be_canceled?
    #   return true if actionable_date.nil?
    #   (actionable_date - 10.days.from_now.to_date) > 0
    # end
    #
    # If a user cancels this subscription less than 10 days before it will
    # be processed the subscription will be bumped into the
    # :pending_cancellation state instead of being canceled. Susbcriptions
    # pending cancellation will still be processed.
    def can_be_canceled?
      return true if actionable_date.nil?
      (actionable_date - Config.minimum_cancellation_notice).future?
    end

    def skip
      check_successive_skips_exceeded
      check_total_skips_exceeded

      return if errors.any?

      advance_actionable_date
    end

    def can_be_activated?
      (end_date ? actionable_date > end_date : true) &&
          line_item.inventory_units.first.shipment.associated_subscription_can_be_activated?
    end

    def was_active?
      state_changes.exists?(next_state: :active)
    end

    def was_canceled?
      state_changes.exists?(next_state: :canceled) &&
        state_changes.where(next_state: :canceled).last.created_at >
          (state_changes.where(next_state: :active).last.try(:created_at) || 0)
    end

    def was_not_canceled?
      !was_canceled?
    end


    # This method determines if a subscription can be deactivated. A deactivated
    # subscription will not be processed. By default a subscription can be
    # deactivated if the end_date defined on
    # subscription_line_item is less than the current date
    # In this case the subscription has been fulfilled and
    # should not be processed again. Subscriptions without an end_date
    # value cannot be deactivated.
    def can_be_deactivated?
      active? && end_date && actionable_date > end_date
    end

    # Get the date after the current actionable_date where this subscription
    # will be actionable again
    #
    # @return [Date] The current actionable_date plus 1 interval. The next
    #   date after the current actionable_date this subscription will be
    #   eligible to be processed.
    def next_actionable_date
      return nil unless active?
      new_date = (actionable_date || Time.zone.now)
      (new_date + (delivery_interval || bill_interval)).beginning_of_minute
    end

    # Advance the actionable date to the next_actionable_date value. Will modify
    # the record.
    #
    # @return [Date] The next date after the current actionable_date this
    # subscription will be eligible to be processed.
    def advance_actionable_date
      update! actionable_date: next_actionable_date
      actionable_date
    end

    # Get the builder for the subscription_line_item. This will be an
    # object that can generate the appropriate line item for the subscribable
    # object
    #
    # @return [SolidusSubscriptions::LineItemBuilder]
    def line_item_builder
      LineItemBuilder.new(line_item)
    end

    # The state of the last attempt to process an installment associated to
    # this subscrtipion
    #
    # @return [String] pending if the no installments have been processed,
    #   failed if the last installment has not been fulfilled and, success
    #   if the last installment was fulfilled.
    def processing_state
      return 'pending' if installments.empty?
      installments.last.fulfilled? ? 'success' : 'failed'
    end

    # Placeholder methods

    def after_cancel
    end

    def after_activate
    end

    def after_deactivate
    end

    private

    def check_successive_skips_exceeded
      return unless Config.maximum_successive_skips

      if successive_skip_count >= Config.maximum_successive_skips
        errors.add(:successive_skip_count, :exceeded)
      end
    end

    def check_total_skips_exceeded
      return unless Config.maximum_total_skips

      if skip_count >= Config.maximum_total_skips
        errors.add(:skip_count, :exceeded)
      end
    end

  end
end
