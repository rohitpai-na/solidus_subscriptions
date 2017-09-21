class AddNumberToSolidusSubscriptionsSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :solidus_subscriptions_subscriptions, :number, :string, index: true
  end
end
