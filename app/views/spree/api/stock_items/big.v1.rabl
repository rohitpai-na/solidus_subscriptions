object @stock_item
# attributes *variant_attributes

attributes :id, :count_on_hand, :backorderable, :price
attribute :available? => :available

child :stock_location => :stock_location do
  extends "spree/api/stock_locations/small"
end

# child :active_subscription_presets => :subscription_presets do
#   extends "spree/api/subscription_presets/show" 
# end

child :supplier => :supplier do
  extends "spree/api/suppliers/small"
end

child (@stock_locations_zipcode ? root_object.determine_adjustments_for_zipcode(@stock_locations_zipcode) : []) => :adjustments do
  extends "spree/api/adjustments/show"
end

node(:total_price) { |obj| obj.total_price }