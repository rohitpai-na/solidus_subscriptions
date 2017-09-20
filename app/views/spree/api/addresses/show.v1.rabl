object @address
cache [I18n.locale, root_object]
attributes *address_attributes - [:company, :company_id, :state_id, :state_name, :state_text]

child(:country) do |address|
  # attributes *country_attributes
  attributes :name
end
child(:state) do |address|
  # attributes *state_attributes
  attributes :name
end
