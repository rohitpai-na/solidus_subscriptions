# Spree::StockLocation may have many subscription_presets. A SubscriptionPreset may
# be selected while placing an order. When the SubscriptionLineItem is created,
# the attributes of the SubscriptionPreset are then copied into the 
# SubscriptionLineItem instance.
module Spree
  module StockLocations
    module SubscriptionPresetsAssociation
      def self.prepended(base)
        base.has_many :subscription_presets, 
                      class_name: "SolidusSubscriptions::SubscriptionPreset",
                      inverse_of: :stock_location
      end
    end
  end
end

Spree::StockLocation.prepend Spree::StockLocations::SubscriptionPresetsAssociation
