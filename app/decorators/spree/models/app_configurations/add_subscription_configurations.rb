module Spree
  module Models
    module AppConfigurations
      module AddSubscriptionConfigurations

        def priceable_type_to_class_mapping
          super if defined?(super)
          @priceable_type_to_class_mapping ||= {}
          @priceable_type_to_class_mapping["subscription_preset"] = SolidusSubscriptions::SubscriptionPreset
          @priceable_type_to_class_mapping
        end

        def priceable_type_to_line_item_type_mapping
          super if defined?(super)
          @priceable_type_to_line_item_type_mapping ||= {}
          @priceable_type_to_line_item_type_mapping["subscription_preset"] = SolidusSubscriptions::LineItem
          @priceable_type_to_line_item_type_mapping
        end
      end
    end
  end
end

Spree::AppConfiguration.prepend(Spree::Models::AppConfigurations::AddSubscriptionConfigurations)