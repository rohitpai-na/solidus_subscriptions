class AddUnitPriceIntervalToSolidusSubscriptionsSubscriptionPreset < SolidusSupport::Migration[4.2]
  def change
    add_column :solidus_subscriptions_subscription_presets, :unit_price_interval_units, :integer
    add_column :solidus_subscriptions_subscription_presets, :unit_price_interval_length, :integer, null: false, default: 1
  end
end
