module Spree
  module Admin
    class SubscriptionPresetsController < ResourceController
      before_action :set_created_by, only: :create
      before_action :set_stock_locations, only: [:index, :create, :update, :new, :edit]
      before_action :set_variants, only: [:create, :update, :new, :edit]

      def collection
        return @collection if @collection
        params[:q] ||= HashWithIndifferentAccess.new
        params[:q][:s] ||= 'created_at desc'
        params[:q][:active_eq] = true if params[:q][:with_inactive].blank? || params[:q][:with_inactive] == "false"

        @collection = super
        @collection = @collection.with_deleted if params[:q][:with_deleted] == "true"
        @search = @collection.ransack(params[:q])
        @collection = @search.result(distinct: true).
          includes(:stock_location, :supplier, :variant).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:personnels_per_page])

        @collection
      end

      def activate
        authorize! :activate, @subscription_preset
        @subscription_preset.activate
        flash[:success] = flash_message_for(@subscription_preset, :successfully_updated)
        redirect_to location_after_save
      end

      def deactivate
        authorize! :deactivate, @subscription_preset
        @subscription_preset.deactivate
        flash[:success] = flash_message_for(@subscription_preset, :successfully_updated)
        redirect_to location_after_save
      end

      private

      def set_created_by
        @subscription_preset.created_by_id = spree_current_user.id
      end

      def set_stock_locations
        @stock_locations = Spree::StockLocation.accessible_by(current_ability, :read).select(:id, :name, :code, :zipcode).all
      end

      def set_variants
        @variants = Spree::Variant.accessible_by(current_ability, :read).select(:id, :name, :sku, :product_id).where(subscribable: true)
      end

      def model_class
        ::SolidusSubscriptions::SubscriptionPreset
      end

    end
  end
end
