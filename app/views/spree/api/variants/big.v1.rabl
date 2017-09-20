object @variant
# attributes *variant_attributes

cache [I18n.locale, Spree::StockLocation.accessible_by(current_ability).pluck(:id).sort.join(":"), 'big_variant', root_object]

extends "spree/api/variants/small"

# node :total_on_hand do
#   root_object.total_on_hand
# end

# child :variant_properties => :variant_properties do
#   attributes *variant_property_attributes
# end

# child(root_object.stock_items.accessible_by(current_ability) => :stock_items) do
child (@stock_locations_zipcode ? root_object.stock_items.by_stock_location_zipcode(@stock_locations_zipcode) : root_object.stock_items) => :stock_items do
  extends "spree/api/stock_items/big"
end

child (@stock_locations_zipcode ? root_object.active_subscription_presets.by_stock_location_zipcode(@stock_locations_zipcode) : root_object.active_subscription_presets) => :subscription_presets do
  extends "spree/api/subscription_presets/show"
end