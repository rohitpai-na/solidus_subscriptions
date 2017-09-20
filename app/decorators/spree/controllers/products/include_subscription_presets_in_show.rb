# Include SubscriptionPreset associated with product variants when
# the show method is invoked.
module Spree
  module Controllers
    module Products
      module IncludeSubscriptionPresetsInShow
        def self.display_includes
          includes(stock_items: [ { stock_location: :active_subscription_presets }, :supplier])
          super
        end
      end
    end
  end
end

Spree::ProductsController.prepend(Spree::Controllers::Products::IncludeSubscriptionPresetsInShow)
