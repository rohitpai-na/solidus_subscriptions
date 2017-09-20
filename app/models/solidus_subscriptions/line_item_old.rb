# # The LineItem class is responsible for associating Line items to subscriptions.  # It tracks the following values:
# #
# # [Spree::LineItem] :spree_line_item The spree object which created this instance
# #
# # [SolidusSubscription::Subscription] :subscription The object responsible for
# #   grouping all information needed to create new subscription orders together
# #
# # [SolidusSubscription::SubscriptionPreset] :subscription_preset The object that contains
# # details like variant, billing_interval, delivery_interval, contract_interval, price etc.
# #
# # [Integer] :quantity How many units of the subscribable should be included in
# #   future orders
# #
# # [Integer] :installments How many subscription orders should be placed
# module SolidusSubscriptions
#   class LineItem < ActiveRecord::Base

#     belongs_to :spree_line_item,     class_name: 'Spree::LineItem', inverse_of: :subscription_line_items
#     has_one    :order,               class_name: 'Spree::Order', through: :spree_line_item
#     belongs_to :subscription,        class_name: 'SolidusSubscriptions::Subscription', inverse_of: :line_items
#     belongs_to :subscription_preset, class_name: 'SolidusSubscriptions::SubscriptionPreset', inverse_of: :line_items
#     has_one    :stock_location,      class_name: 'Spree::StockLocation', through: :subscription_preset
#     belongs_to :supplier,            class_name: 'Spree::Supplier', inverse_of: :subscription_line_items

#     # interval_enum length_attr: true

#     validates :subscription_preset, presence: true
#     # validates :subscribable_id, presence: :true
#     validates :quantity, numericality: { greater_than: 0 }
#     # validates :interval_length, numericality: { greater_than: 0 }, unless: -> { subscription }

#     before_save :set_supplier_id
#     # before_update :update_actionable_date_if_interval_changed

#     delegate :delivery_interval, :delivery_interval_units, :delivery_interval_length, to: :subscription_preset
#     delegate :bill_interval,     :bill_interval_units,     :bill_interval_length,     to: :subscription_preset
#     delegate :contract_interval, :contract_interval_units, :contract_interval_length, to: :subscription_preset
#     delegate :interval,          :interval_units,          :interval_length,          to: :subscription_preset

#     class << self
#       delegate :interval_units, to: :"SolidusSubscriptions::SubscriptionPreset"
#     end

#     def next_actionable_date
#       dummy_subscription.next_actionable_date
#     end

#     def as_json(**options)
#       options[:methods] ||= [:dummy_line_item, :next_actionable_date]
#       super(options)
#     end

#     # Get a placeholder line item for calculating the values of future
#     # subscription orders. It is frozen and cannot be saved
#     def dummy_line_item
#       li = LineItemBuilder.new([self]).spree_line_items.first
#       return unless li

#       li.order = dummy_order
#       li.validate
#       li.freeze
#     end

#     # def interval
#     #   subscription.try!(:interval) || super
#     # end

#     private

#     # Get a placeholder order for calculating the values of future
#     # subscription orders. It is a frozen duplicate of the current order and
#     # cannot be saved
#     def dummy_order
#       order = spree_line_item ? spree_line_item.order.dup : Spree::Order.create
#       order.ship_address = subscription.shipping_address || subscription.user.ship_address if subscription

#       order.freeze
#     end

#     # A place holder for calculating dynamic values needed to display in the cart
#     # it is frozen and cannot be saved
#     def dummy_subscription
#       Subscription.new(line_items: [dup]).freeze#, interval_length: interval_length, interval_units: interval_units).freeze
#     end

#     # def update_actionable_date_if_interval_changed
#     #   if persisted? && subscription && (interval_length_changed? || interval_units_changed?)
#     #     base_date = if subscription.installments.any?
#     #       subscription.installments.last.created_at
#     #     else
#     #       subscription.created_at
#     #     end

#     #     new_date = interval.since(base_date)

#     #     if new_date < Time.zone.now
#     #       # if the chosen base time plus the new interval is in the past, set
#     #       # the actionable_date to be now to avoid confusion and possible
#     #       # mis-processing.
#     #       new_date = Time.zone.now
#     #     end

#     #     subscription.actionable_date = new_date
#     #   end
#     # end

#     private

#     def set_supplier_id
#       self.supplier_id = self.subscription_preset.supplier_id
#     end

#   end
# end
