object @line_item
extends "spree/api/line_items/show"

attribute :priceable_id
node(:priceable_type) {|li| li.priceable_type_constant }

child :priceable => :priceable do
  node do |priceable|
    partial "spree/api/#{priceable.class.name.demodulize.underscore.pluralize}/as_priceable", :object => priceable
  end
end