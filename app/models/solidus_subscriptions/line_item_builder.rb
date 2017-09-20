# This class is responsible for taking SubscriptionLineItems and building
# them into Spree::LineItems which can be added to an order
module SolidusSubscriptions
  class LineItemBuilder
    attr_reader :subscription_line_item

    # Get a new instance of a LineItemBuilder
    #
    # @param subscription_line_items[SolidusSubscriptions::LineItem] The
    #   subscription line item to be converted into a Spree::LineItem
    #
    # @return [SolidusSubscriptions::LineItemBuilder]
    def initialize(subscription_line_item)
      @subscription_line_item = subscription_line_item
    end

    # Get a new (unpersisted) Spree::LineItem which matches the details of
    # :subscription_line_item
    #
    # @return [Spree::LineItem]
    def spree_line_items
      variant = subscription_line_item.variant
      raise UnsubscribableError.new(variant) unless variant.subscribable?

      line_item = nil
      if variant.can_supply?(subscription_line_item.quantity)
        line_item = Spree::LineItem.new(variant: variant, quantity: subscription_line_item.quantity, 
          priceable: subscription_line_item.priceable)
      end

      # Either all line items for an installment are fullfilled or none are
      #line_items.all? ? line_items : []
      line_item ? [line_item] : []
    end

  end
end
