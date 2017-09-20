module Spree
  module LineItems
    module PriceableFriendly
      def priceable_type_constant
        Rails.logger.debug "************************** subscription #{__method__}"
        defined?(:priceable_type) ? Spree::Config.priceable_type_to_class_mapping.select{|k,v| v == priceable_type.constantize}.keys.first : nil
      end
    end
  end
end

Spree::LineItem.prepend(Spree::LineItems::PriceableFriendly)
