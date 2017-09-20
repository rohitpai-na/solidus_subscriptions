class AddLineItemReferenceToSolidusSubscriptionsSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_reference :solidus_subscriptions_subscriptions, :line_item, foreign_key: true
  end
end
