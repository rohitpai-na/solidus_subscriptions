module SolidusSubscriptions
  class SubscriptionPreset < ActiveRecord::Base
    include Spree::DefaultPriceForPriceable
    
    acts_as_paranoid

    belongs_to :variant,
      class_name: "Spree::Variant",
      inverse_of: :subscription_presets

    belongs_to :stock_location,
      class_name: "Spree::StockLocation",
      inverse_of: :subscription_presets
    
    belongs_to :supplier, 
      class_name: 'Spree::Supplier',
      inverse_of: :subscription_presets
    
    belongs_to :created_by,
      class_name: Spree.user_class
    
    has_many :subscriptions,  
      class_name: "SolidusSubscriptions::Subscription", 
      inverse_of: :subscription_preset
    
    has_many :subscription_line_items,
      class_name: "SolidusSubscriptions::SubscriptionLineItem",
      through: :subscriptions
    

    interval_enum _prefix: :delivery,   
      length_attr: true, 
      only: [:years, :halfyears, :quarters, :months, :weeks, :days]
    
    interval_enum _prefix: :bill,
      length_attr: true,
      only: [:years, :halfyears, :quarters, :months, :weeks, :days]
    
    interval_enum _prefix: :contract,
      length_attr: true,
      only: [:months, :days]
    
    interval_enum _prefix: :unit_price,
      length_attr: true,
      only: [:days, :hours, :minutes, :seconds]
    

    enum payment_category:  %i(fixed variable),      _prefix: :payment_category
    enum payment_mode:      %i(pre post),            _prefix: :payment_mode
    enum delivery_category: %i(periodic continuous), _prefix: :delivery_category

    validates_presence_of :variant, :stock_location, :payment_category,
      :payment_mode, :delivery_category, :deposit_amount,
      :bill_interval_length, :bill_interval_units,
      :contract_interval_length, :contract_interval_units,
      :unit_price, :unit_price_interval_units
    
    validates_presence_of :delivery_interval_units,
      unless: -> { delivery_category_continuous? }
    
    validates :delivery_interval_length,
      presence: true,
      numericality: { only_integer: true, greater_than: 0 },
      unless: -> { delivery_category_continuous? } 

    validates :bill_interval_length, :bill_price_due_time,
      :contract_interval_length,
      numericality: { only_integer: true, greater_than: 0 }

    validates :bill_price,
      presence: true,
      numericality: { greater_than_or_equal_to: 0 },
      unless: -> { payment_category_variable? }

    validates :unit_price,
      numericality: { greater_than_or_equal_to: 0 }
    
    # validates :unit_price,               presence: true, numericality: { greater_than_or_equal_to: 0 }#, if: -> { pro_rata }
    # validates :contract_interval_length, presence: true, numericality: { only_integer: true, greater_than: 0 }
    # validates :delivery_interval_length, presence: true, numericality: { only_integer: true, greater_than: 0 }, unless: -> { delivery_category_continuous? } 
    # validates :delivery_interval_units,  presence: true, unless: -> { delivery_category_continuous? }
    # validates :bill_price_due_time,      numericality: { only_integer: true, greater_than: 0 }

    validates_uniqueness_of :variant_id, 
      scope: [:stock_location_id, :payment_category, :payment_mode,
              :bill_interval_units, :bill_interval_length, :delivery_category,
              :delivery_interval_units, :delivery_interval_length,
              :contract_interval_units, :contract_interval_length] if Proc.new { |sp| 
                sp.deleted_at.blank? && !sp.delivery_category_continuous? }
    
    validates_uniqueness_of :variant_id,
      scope: [:stock_location_id, :payment_category, :payment_mode,
              :bill_interval_units, :bill_interval_length, :delivery_category, 
              :contract_interval_units, :contract_interval_length] if Proc.new { |sp| 
                sp.deleted_at.blank? && sp.delivery_category_continuous? }

    before_save :set_supplier_id
    before_save :set_price

    class << self
      def interval_units
        delivery_interval_units
      end
    end

    alias_method :interval, :delivery_interval

    def interval_units
      delivery_interval_units
    end

    def interval_length
      delivery_interval_length
    end

    def activate
      update_attributes(active: true)
    end

    def deactivate
      update_attributes(active: false)
    end

    private

    def set_supplier_id
      self.supplier_id = self.stock_location.supplier_id
    end

    def set_price
      self.price = self.deposit_amount
    end
  end
end
