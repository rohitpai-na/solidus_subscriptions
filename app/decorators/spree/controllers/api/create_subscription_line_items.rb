# # Create new subscription line items associated to the current order, when
# # a line item is added to the cart which includes subscription_line_item
# # params.
# #
# # The Subscriptions::LineItem acts as a line item place holder for a
# # Subscription, indicating that it has been added to the order, but not
# # yet purchased
# module Spree
#   module Controllers::Api::CreateSubscriptionLineItems
#     include SolidusSubscriptions::SubscriptionLineItemBuilder

#     def self.prepended(base)
#       base.before_action(
#         :set_subscribable,
#         only: [:create, :update],
#         if: ->{ params[:order] && params[:order][:subscription_line_item] && params[:order][:subscription_line_item][:quantity] && params[:order][:subscription_line_item][:quantity] > 0 }
#       )
#       base.after_action(
#         :handle_subscription_line_items,
#         only: [:create, :update],
#         if: ->{ params[:subscription_line_item] && params[:subscription_line_item][:quantity] && params[:subscription_line_item][:quantity] > 0 }
#       )
#     end

#     private

#     def set_subscribable
#       puts "******************************** set_subscribable"
#       subscription_line_item_attributes = params[:order].delete(:subscription_line_item)
#       params[:subscription_line_item] = subscription_line_item_attributes
#       @subscribable = Spree::Variant.find_by(id: subscription_line_item_attributes[:variant_id]) if subscription_line_item_attributes[:variant_id]
#       @subscribable ||= SolidusSubscriptions::SubscriptionPreset.find_by(id: subscription_line_item_attributes[:subscription_preset_id]).try(:variant) if subscription_line_item_attributes[:subscription_preset_id]
#       subscription_line_item_attributes[:subscribable_id] = @subscribable.id if @subscribable
#       puts "#{@subscribable.inspect}"
#       puts "#{params.inspect}"
#     end

#     def handle_subscription_line_items
#       puts "******************************** handle_subscription_line_items"
#       puts "#{@order.inspect}"
#       puts "#{@line_item.inspect}"
#       @line_item ||= @order.line_items.find_by(variant_id: @subscribable.id) if @subscribable && @order
#       @order ||= @line_item.order if @line_item
#       puts "#{@line_item.inspect}"
#       if @line_item && @line_item.valid?
#         subscription_line_item = create_subscription_line_item(@line_item)
#         # SolidusSubscriptions::SubscriptionGenerator.group(subscription_line_items).each do |line_items|
#           SolidusSubscriptions::SubscriptionGenerator.activate([subscription_line_item])
#         # end
#       end
#     rescue StandardError => e
#       @order.canceled_by(current_api_user) if @order
#       raise e
#     end
#   end
# end
