cache [I18n.locale, 'subscription_preset', root_object]

# attributes *subscription_preset_attributes - [:supplier_id]
attributes :id, :name, :description, :payment_category, :payment_mode, :deposit_amount, :deposit_refundable, :deposit_due_time, :bill_interval_units, :bill_interval_length, :bill_price, :bill_price_due_time, :bill_fine, :delivery_category, :delivery_interval_units, :delivery_interval_length, :unit_price, :pro_rata, :max_outstanding_amount, :contract_interval_units, :contract_interval_length

# child :supplier => :supplier do
#   extends "spree/api/suppliers/small"
# end

child :stock_location => :stock_location do
  extends "spree/api/stock_locations/small"
end

child :supplier => :supplier do
  extends "spree/api/stock_locations/small"
end

child (@stock_locations_zipcode ? root_object.determine_adjustments_for_zipcode(@stock_locations_zipcode) : []) => :adjustments do
  extends "spree/api/adjustments/show"
end

node(:total_price) { |obj| obj.total_price }