# Spree::Product maintain a list of the subscription_presets associated with them
module Spree
  module Products
    module HaveManySubscritptionPresets
      def self.prepended(base)
        base.has_many(
          :subscription_presets,
          class_name: 'SolidusSubscriptions::SubscriptionPreset',
          through: :variants_including_master
        )

        base.has_many(
          :active_subscription_presets,
          class_name: 'SolidusSubscriptions::SubscriptionPreset',
          through: :variants_including_master
        )
      end
    end
  end
end

Spree::Product.prepend(Spree::Products::HaveManySubscritptionPresets)
