class AddSupplierIdToSolidusSubscriptionsTables < SolidusSupport::Migration[4.2]
  def change
    add_column :solidus_subscriptions_subscriptions, :supplier_id, :integer, index: true
    add_column :solidus_subscriptions_line_items, :supplier_id, :integer, index: true
    add_column :solidus_subscriptions_subscription_presets, :supplier_id, :integer, index: true
  end
end
