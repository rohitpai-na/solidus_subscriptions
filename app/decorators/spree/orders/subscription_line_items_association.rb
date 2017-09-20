# Spree::Orders may contain many subscription_line_items. When the order is
# finalized these subscription_line_items are converted into subscritpions.
# The order needs to be able to get a list of associated subscription_line_items
# to be able to populate the full subscriptions.
module Spree
  module Orders
    module SubscriptionLineItemsAssociation
      def self.prepended(base)
        base.has_many :subscription_line_items, class_name: "SolidusSubscriptions::LineItem"
        base.has_many :subscriptions, through: :subscription_line_items, source: :subscription
      end
    end
  end
end

Spree::Order.prepend Spree::Orders::SubscriptionLineItemsAssociation
