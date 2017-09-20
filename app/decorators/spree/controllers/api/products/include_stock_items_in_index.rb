module Spree
  module Controllers
    module Api
      module Products
        module IncludeStockItemsInIndex
          def self.prepended(base)
            base.before_action(
              :set_filter_stock_locations_zipcode,
              only: [:index]#,
              # if: ->{ params[:q] && params[:q][:stock_locations_zipcode_eq] }
            )
          end

          def set_filter_stock_locations_zipcode
            @stock_locations_zipcode = params[:q].try(:[], :stock_locations_zipcode_eq)
            puts "************************************ stock_locations_zipcode: #{@stock_locations_zipcode}"
          end

          # def self.prepended(base)
          #   base.after_action(
          #     :filter_by_stock_locations_zipcode,
          #     only: [:index],
          #     if: ->{ params[:q] && params[:q][:stock_locations_zipcode_eq] }
          #   )
          # end

          def index
            if params[:ids]
              ids = params[:ids].split(",").flatten
              @products = product_scope.where(id: ids)
            else
              @products = product_scope.ransack(params[:q]).result
            end

            @products = paginate(@products.distinct)
            # filter_by_stock_locations_zipcode
            expires_in 15.minutes, public: true
            headers['Surrogate-Control'] = "max-age=#{15.minutes}"
            respond_with(@products)
          end

          def variants_associations
            super << { stock_items: { stock_location: :active_subscription_presets } }
          end

          # def filter_by_stock_locations_zipcode
          #   if params[:q] && params[:q][:stock_locations_zipcode_eq]
          #     @products.each do |product|
          #       product.variants.each{ |variant| variant.stock_items.each { |si| puts "************************* Reject #{si.stock_location.name}" if si.stock_location.zipcode != params[:q][:stock_locations_zipcode_eq] } }
          #       product.variants.each{ |variant| variant.stock_items.reject { |si| si.stock_location.zipcode != params[:q][:stock_locations_zipcode_eq] } }
          #       product.master.stock_items.reject { |si| si.stock_location.zipcode != params[:q][:stock_locations_zipcode_eq]}
          #     end
          #   end
          # end
        end
      end
    end
  end
end

Spree::Api::ProductsController.prepend(Spree::Controllers::Api::Products::IncludeStockItemsInIndex)
