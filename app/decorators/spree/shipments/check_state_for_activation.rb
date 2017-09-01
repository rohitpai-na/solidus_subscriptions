module Spree
  module Shipments
    module CheckStateForActivation
      def can_be_activated?
        installed? || (delivered? && !manifest_variants_need_installation?)
      end
    end

    Shipment.prepend(CheckStateForActivation)
  end
end
