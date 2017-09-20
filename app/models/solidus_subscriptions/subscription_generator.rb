# This module is responsible for taking SolidusSubscriptions::LineItem
# objects and creating SolidusSubscriptions::Subscription Objects
module SolidusSubscriptions
  module SubscriptionGenerator
    extend self

    # Create and persist a subscription for a collection of subscription
    #   line items
    #
    # @param subscription_line_item [SolidusSubscriptions::LineItem] The
    #   subscription_line_item to be activated
    #
    # @return [SolidusSubscriptions::Subscription]
    def activate(subscription_line_item)
      Rails.logger.debug "******************** subscription_generator #{__method__}"
      return if subscription_line_item.blank?

      subscription_preset = subscription_line_item.priceable
      return if subscription_preset.blank?

      subscription_line_item = SolidusSubscriptions::LineItem.find(subscription_line_item.id)
      subscription_attributes = {
        line_item: subscription_line_item,
        subscription_preset: subscription_preset,
        supplier_id: subscription_preset.supplier_id
      }
      Rails.logger.debug "******************** subscription_generator #{subscription_attributes.inspect}"

      if subscription_line_item.subscription.present?
      # if (subscription = Subscription.find_by(line_item_id: subscription_line_item.id))
        Rails.logger.debug "******************** subscription_generator update"
        subscription_line_item.subscription.update(subscription_attributes)
      else
        Rails.logger.debug "******************** subscription_generator create"
        Subscription.create!(subscription_attributes)
      end
    end

  end
end
