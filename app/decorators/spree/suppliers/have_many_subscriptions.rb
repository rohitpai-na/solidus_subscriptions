# Spree::Supplier maintain a list of the subscriptions associated with them
module Spree
  module Suppliers
    module HaveManySubscritptions
      def self.prepended(base)
        base.has_many(
          :subscriptions,
          class_name: 'SolidusSubscriptions::Subscription',
          foreign_key: 'supplier_id',
          inverse_of: :supplier
        )

        base.has_many(
          :subscription_line_items,
          class_name: 'SolidusSubscriptions::LineItem',
          foreign_key: 'supplier_id',
          inverse_of: :supplier
        )

        base.has_many(
          :subscription_presets,
          class_name: 'SolidusSubscriptions::SubscriptionPreset',
          foreign_key: 'supplier_id',
          inverse_of: :supplier
        )

      end
    end
  end
end

Spree::Supplier.prepend(Spree::Suppliers::HaveManySubscritptions)
