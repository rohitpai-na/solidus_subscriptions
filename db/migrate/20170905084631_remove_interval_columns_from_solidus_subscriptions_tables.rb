class RemoveIntervalColumnsFromSolidusSubscriptionsTables < SolidusSupport::Migration[4.2]
  def change
    remove_column :solidus_subscriptions_subscriptions, :interval_units
    remove_column :solidus_subscriptions_line_items,    :interval_units    
    remove_column :solidus_subscriptions_subscriptions, :interval_length
    remove_column :solidus_subscriptions_line_items,    :interval_length
  end
end
