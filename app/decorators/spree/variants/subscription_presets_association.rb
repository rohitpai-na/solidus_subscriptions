# Spree::Variant may have many subscription_presets. A SubscriptionPreset may
# be selected while placing an order. When the SubscriptionLineItem is created,
# the attributes of the SubscriptionPreset are then copied into the 
# SubscriptionLineItem instance.
module Spree
  module Variants
    module SubscriptionPresetsAssociation
      def self.prepended(base)
        base.has_many :subscription_presets, 
                      class_name: "SolidusSubscriptions::SubscriptionPreset",
                      inverse_of: :variant

        # base.has_many :active_subscription_presets,
        #               -> { where SolidusSubscriptions::SubscriptionPreset.arel_table[:active].eq(true) },
        #               class_name: "SolidusSubscriptions::SubscriptionPreset"

        base.has_many :active_subscription_presets,
                      -> { where SolidusSubscriptions::SubscriptionPreset.arel_table[:active].eq(true) },
                      class_name: "SolidusSubscriptions::SubscriptionPreset" do
                        def by_stock_location_zipcode(zipcode)
                          joins(:stock_location).where(Spree::StockLocation.arel_table[:zipcode].eq(zipcode))
                        end
                      end

        base.has_many :stock_items do
                        def by_stock_location_zipcode(zipcode)
                          joins(:stock_location).where(Spree::StockLocation.arel_table[:zipcode].eq(zipcode))
                        end
                      end
      end
    end
  end
end

Spree::Variant.prepend Spree::Variants::SubscriptionPresetsAssociation
