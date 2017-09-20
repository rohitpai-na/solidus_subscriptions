module Spree
  module Admin
    class SubscriptionsController < ResourceController
      skip_before_action :load_resource, only: :index
      before_action :load_subscription_presets, only: [:new, :edit]

      def index
        @search = SolidusSubscriptions::Subscription.
          accessible_by(current_ability, :index).ransack(params[:q])

        @subscriptions = @search.result(distinct: true).
          includes(:line_item, :user).
          joins(:line_item, :user).
          includes(line_item: :subscription_preset).
          joins(line_item: :subscription_preset).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])
      end

      # def new
      #   @subscription
      # end

      def cancel
        @subscription.transaction do
          @subscription.actionable_date = nil
          @subscription.cancel
        end

        if @subscription.errors.none?
          notice = I18n.t('spree.admin.subscriptions.successfully_canceled')
        else
          notice = @subscription.errors.full_messages.to_sentence
        end

        redirect_to spree.admin_subscriptions_path, notice: notice
      end

      def activate
        @subscription.activate

        if @subscription.errors.none?
          notice = I18n.t('spree.admin.subscriptions.successfully_activated')
        else
          notice = @subscription.errors.full_messages.to_sentence
        end

        redirect_to spree.admin_subscriptions_path, notice: notice
      end

      # def skip
      #   @subscription.advance_actionable_date

      #   notice = I18n.t(
      #     'spree.admin.subscriptions.successfully_skipped',
      #     date: @subscription.actionable_date
      #   )

      #   redirect_to spree.admin_subscriptions_path, notice: notice
      # end

      private

      def load_subscription_presets
        @subscription_presets = SolidusSubscriptions::SubscriptionPreset.
          accessible_by(current_ability, :index).all
      end
        
      def model_class
        ::SolidusSubscriptions::Subscription
      end
    end
  end
end
