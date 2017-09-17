module SolidusSubscriptions
  class SubscriptionPreset < ActiveRecord::Base
    acts_as_paranoid

    belongs_to :variant,        class_name: "Spree::Variant",       inverse_of: :subscription_presets
    belongs_to :stock_location, class_name: "Spree::StockLocation", inverse_of: :subscription_presets

    interval_enum _prefix: :delivery, length_attr: true
    interval_enum _prefix: :bill,     length_attr: true
    interval_enum _prefix: :contract, length_attr: true, only: [:months, :days]

    enum payment_category:  %i(fixed variable)
    enum payment_mode:      %i(pre post)
    enum delivery_category: %i(periodic continuous)

    validates_presence_of :variant, :stock_location
    validates_presence_of :payment_category, :payment_mode
    validates_presence_of :deposit_amount
    validates_presence_of :bill_interval_units, :bill_interval_length, :bill_price, :bill_fine
    validates_presence_of :delivery_category, :delivery_interval_units, :delivery_interval_length
    validates_presence_of :unit_price, :contract_interval_units, :contract_interval_length

    validates_uniqueness_of :variant_id, scope: [:stock_location_id, :payment_category, :payment_mode, :deposit_refundable, :bill_interval_units, :bill_interval_length, :delivery_category, :delivery_interval_units, :delivery_interval_length, :contract_interval_units, :contract_interval_length] unless :deleted_at
  end
end
