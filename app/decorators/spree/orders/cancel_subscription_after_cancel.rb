module Spree
  module Orders
    module CancelSubscriptionAfterCancel
      def after_cancel
        Rails.logger.debug "************************* #{__method__}"
        Rails.logger.debug "#{subscriptions.inspect}"
        subscriptions.each(&:cancel)
        super
      end

      def send_cancel_email
        super unless subscription_order?
      end
    end
  end
end

Spree::Order.prepend(Spree::Orders::CancelSubscriptionAfterCancel)
