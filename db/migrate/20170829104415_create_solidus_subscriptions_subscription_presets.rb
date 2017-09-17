class CreateSolidusSubscriptionsSubscriptionPresets < SolidusSupport::Migration[4.2]
  def change
    create_table :solidus_subscriptions_subscription_presets do |t|
      t.references :variant,                  index: true, foreign_key: true
      t.references :stock_location,           index: { name: "index_solidus_subscriptions_subs_presets_stk_locations" }, foreign_key: true
      t.string     :name,                     null: false, index: true
      t.text       :description
      t.integer    :payment_category,         null: false
      t.integer    :payment_mode,             null: false
      t.decimal    :deposit_amount,           precision: 10, scale: 2, null: false, default: 0.0
      t.boolean    :deposit_refundable
      t.integer    :deposit_due_time
      t.integer    :bill_interval_units,      null: false
      t.integer    :bill_interval_length,     null: false, default: 1
      t.decimal    :bill_price,               precision: 10, scale: 2, null: false, default: 0.0
      t.integer    :bill_price_due_time
      t.decimal    :bill_fine,                precision: 10, scale: 2, null: false, default: 0.0
      t.integer    :delivery_category,        null: false
      t.integer    :delivery_interval_units
      t.integer    :delivery_interval_length
      t.decimal    :unit_price,               precision: 10, scale: 2, null: false, default: 0.0
      t.boolean    :pro_rata
      t.decimal    :max_outstanding_amount,   precision: 10, scale: 2
      t.integer    :contract_interval_units,  null: false
      t.integer    :contract_interval_length, null: false
      t.boolean    :active,                   null: false, default: true, index: true
      t.integer    :created_by_id,            null: false, index: { name: "index_solidus_subscriptions_subs_presets_created_by" }
      t.datetime   :deleted_at

      t.timestamps
    end
    # add_index :solidus_subscriptions_subscription_presets, [:variant_id, :stock_location_id, :payment_category, :payment_mode, :deposit_refundable, :bill_interval_units, :bill_interval_length, :delivery_category, :delivery_interval_units, :delivery_interval_length, :contract_interval_units, :contract_interval_length, :deleted_at], name: "index_solidus_subscriptions_subscription_presets_unique", unique: true
  end
end
