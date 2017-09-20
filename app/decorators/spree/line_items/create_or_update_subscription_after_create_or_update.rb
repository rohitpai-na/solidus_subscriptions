module Spree
  module LineItems
    module CreateOrUpdateSubscriptionAfterCreateOrUpdate
      def self.prepended(base)
        base.after_create :create_or_update_subscription_from_line_item
        base.after_update :create_or_update_subscription_from_line_item
      end

      def create_or_update_subscription_from_line_item
        Rails.logger.debug "************************** subscription #{__method__}"
        SolidusSubscriptions::SubscriptionGenerator.activate self if type == SolidusSubscriptions::LineItem.name
      end
    end
  end
end

Spree::LineItem.prepend(
  Spree::LineItems::CreateOrUpdateSubscriptionAfterCreateOrUpdate)
