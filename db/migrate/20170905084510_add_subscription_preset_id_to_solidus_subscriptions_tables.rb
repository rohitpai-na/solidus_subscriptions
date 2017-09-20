class AddSubscriptionPresetIdToSolidusSubscriptionsTables < SolidusSupport::Migration[4.2]
  def change
    add_reference :solidus_subscriptions_subscriptions, :subscription_preset, foreign_key: true
    add_reference :solidus_subscriptions_line_items,    :subscription_preset, foreign_key: true
  end
end
