module SolidusSubscriptions
  class Ability
    include CanCan::Ability

    def initialize(user)
      alias_action :create, :read, :update, :destroy, to: :crud

      if user.has_spree_role?('admin')
        can(:manage, LineItem)
        can(:manage, Subscription)
        can(:manage, SubscriptionPreset)
      elsif user.has_spree_role?('supplier') || user.supplier
        can [:admin, :display, :show], SolidusSubscriptions::LineItem, supplier_id: user.supplier_id
        can [:admin, :display, :show], SolidusSubscriptions::Subscription, supplier_id: user.supplier_id
        can [:admin, :create], SolidusSubscriptions::SubscriptionPreset
        can [:activate, :deactivate, :display, :show], SolidusSubscriptions::SubscriptionPreset, supplier_id: user.supplier_id
      else
        can([:crud, :skip, :cancel], Subscription, user_id: user.id)
        can(:crud, LineItem) do |li, order|
          li.order.user == user || li.order == order
        end
      end
    end
  end
end
