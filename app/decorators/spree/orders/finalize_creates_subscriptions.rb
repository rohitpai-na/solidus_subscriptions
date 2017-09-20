# Once an order is finalized its subscriptions line items should be converted
# into active subscritptions. This hooks into Spree::Order#finalize! and
# passes all subscription_line_items present on the order to the Subscription
# generator which will build and persist the subscriptions
module Spree
  module Orders
    module FinalizeCreatesSubscriptions
      def finalize!
        Rails.logger.debug "******************** subscription #{__method__}"
        super
        Rails.logger.debug "******************** back in subscription #{__method__}"
        create_or_update_subscription
      end

      # Spree::Order.register_update_hook :create_or_update_subscription

      def create_or_update_subscription
        Rails.logger.debug "******************** subscription #{__method__}"
        subscription_line_items.each do |line_item|
          SolidusSubscriptions::SubscriptionGenerator.activate(line_item)
        end
      end
    end
  end
end

Spree::Order.prepend Spree::Orders::FinalizeCreatesSubscriptions
