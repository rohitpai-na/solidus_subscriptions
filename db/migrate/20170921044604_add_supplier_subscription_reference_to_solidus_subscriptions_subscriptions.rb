class AddSupplierSubscriptionReferenceToSolidusSubscriptionsSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :solidus_subscriptions_subscriptions, :supplier_subscription_reference, :string
    add_index :solidus_subscriptions_subscriptions, [:supplier_subscription_reference, :supplier_id], unique: true, name: "index_solidus_subscriptions_subs_on_supplier_subs_ref"
  end
end
