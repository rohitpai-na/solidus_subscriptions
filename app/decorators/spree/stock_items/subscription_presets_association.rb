
module Spree
  module StockItems
    module SubscriptionPresetsAssociation
      def subscription_presets
        stock_location.subscription_presets.where(variant_id: variant_id)
      end

      def active_subscription_presets
        stock_location.active_subscription_presets.where(variant_id: variant_id)
      end
    end
  end
end

Spree::StockItem.prepend Spree::StockItems::SubscriptionPresetsAssociation
