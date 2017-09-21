module Spree
  module Shipments
    module SubscriptionLineItemsAssociation
      def self.prepended(base)
        base.has_many :subscription_line_items, through: :inventory_units
        base.has_many :subscriptions, through: :inventory_units
      end
    end
  end
end

Spree::Shipment.prepend Spree::Shipments::SubscriptionLineItemsAssociation
