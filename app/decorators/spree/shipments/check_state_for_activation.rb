module Spree
  module Shipments
    module CheckStateForActivation
      def associated_subscription_can_be_activated?
        installed? || (delivered? && !manifest_variants_need_installation?)
      end

      def after_deliver
        activate_associated_subscription
        super
      end

      def after_install
        activate_associated_subscription
        super
      end

      def activate_associated_subscription
        line_items.each do |line_item|
          subscription = line_item.try(:subscription)
          subscription.activate! if subscription && !subscription.active? && 
              associated_subscription_can_be_activated?
        end
      end
    end

    Shipment.prepend(CheckStateForActivation)
  end
end
