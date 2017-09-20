class RemoveUserStoreShippingAddressFromSolidusSubscriptionsSubscriptions < SolidusSupport::Migration[4.2]
  def change
    remove_column :solidus_subscriptions_subscriptions, :user_id
    remove_column :solidus_subscriptions_subscriptions, :store_id
    remove_column :solidus_subscriptions_subscriptions, :shipping_address_id
  end
end
