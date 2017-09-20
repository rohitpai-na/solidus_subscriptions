object @adjustment
cache [I18n.locale, root_object]
attributes :amount, :label
node(:display_amount) { |a| a.display_amount.to_s }
