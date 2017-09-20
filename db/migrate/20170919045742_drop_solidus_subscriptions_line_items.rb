class DropSolidusSubscriptionsLineItems < ActiveRecord::Migration[4.2]
  def change
    drop_table :solidus_subscriptions_line_items
  end
end
