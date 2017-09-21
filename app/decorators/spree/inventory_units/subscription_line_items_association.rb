module Spree
  module InventoryUnits
    module SubscriptionLineItemsAssociation
      def self.prepended(base)
        base.belongs_to :subscription_line_item, class_name: "SolidusSubscriptions::LineItem", foreign_key: :line_item_id
        base.has_one :subscription, through: :subscription_line_item
      end
    end
  end
end

Spree::InventoryUnit.prepend Spree::InventoryUnits::SubscriptionLineItemsAssociation
