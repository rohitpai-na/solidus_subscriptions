module ActiveSupport
  class Duration

    SECONDS_PER_QUARTER = 7889238
    SECONDS_PER_HALFYEAR = 15778476

    PARTS_IN_SECONDS = {
      seconds:   1,
      minutes:   SECONDS_PER_MINUTE,
      hours:     SECONDS_PER_HOUR,
      days:      SECONDS_PER_DAY,
      weeks:     SECONDS_PER_WEEK,
      months:    SECONDS_PER_MONTH,
      quarters:  SECONDS_PER_QUARTER,
      halfyears: SECONDS_PER_HALFYEAR,
      years:     SECONDS_PER_YEAR
    }.freeze

    PARTS = [:years, :halfyears, :quarters, :months, :weeks, :days, :hours, :minutes, :seconds].freeze

    class << self

      def quarters(value) #:nodoc:
        new(value * SECONDS_PER_QUARTER, [[:quarters, value]])
      end

      def halfyears(value) #:nodoc:
        new(value * SECONDS_PER_HALFYEAR, [[:halfyears, value]])
      end

    end

  end
end

class Integer

  def quarters
    ActiveSupport::Duration.quarters(self)
  end
  alias :quarter :quarters

  def halfyears
    ActiveSupport::Duration.halfyears(self)
  end
  alias :halfyear :halfyears

end

class Date

  def advance(options)
    options = options.dup
    d = self
    d = d >> options.delete(:years) * 12    if options[:years]
    d = d >> options.delete(:halfyears) * 6 if options[:halfyears]
    d = d >> options.delete(:quarters) * 3  if options[:quarters]
    d = d >> options.delete(:months)        if options[:months]
    d = d +  options.delete(:weeks) * 7     if options[:weeks]
    d = d +  options.delete(:days)          if options[:days]
    d
  end

end


module ActiveRecord
  class Base
    INTERVAL_UNITS = {
      years:     0,
      halfyears: 1,
      quarters:  2,
      months:    3,
      weeks:     4,
      days:      5,
      hours:     6,
      minutes:   7,
      seconds:   8
    }.freeze

    def self.interval_enum(definition = {})
      # Rails.logger.info "definition : #{definition}"

      enum_name         = definition.delete(:name) ||
                              ([true, false].include?(definition[:_prefix]) ? nil : definition[:_prefix]) ||
                              ([true, false].include?(definition[:_suffix]) ? nil : definition[:_suffix])
      units_attr        = definition.delete(:units_attr) ||
                              [enum_name.to_s, "interval_units"].reject(&:blank?).join("_").to_sym
      length_attr       = definition.delete(:length_attr) 
      length_attr       = [enum_name.to_s, "interval_length"].reject(&:blank?).join("_").to_sym if length_attr == true
      interval_method   = definition.delete(:interval_method) ||
                              [enum_name.to_s, "interval"].reject(&:blank?).join("_").to_sym
      only              = definition.delete(:only)
      except            = definition.delete(:except)
      prefix            = [definition[:_prefix], "interval_units"].reject(&:blank?).join("_").to_sym unless [true, false].include?(definition[:_prefix])
      suffix            = [definition[:_suffix], "interval_units"].reject(&:blank?).join("_").to_sym unless definition[:_suffix].blank? || [true, false].include?(definition[:_suffix])

      filtered_units    = INTERVAL_UNITS.except(*except)
      filtered_units    = filtered_units.slice(*only) unless only.blank?


      definition[units_attr] = filtered_units
      definition[:_prefix]   = prefix
      definition[:_suffix]   = suffix
      # Rails.logger.info "definition : #{definition}"

      interval_unit_enum = enum definition

      define_method(interval_method) do

        return nil if length_attr.blank? || self.send(length_attr).blank? || units_attr.blank? || self.send(units_attr).blank?
        ActiveSupport::Duration.new(
          self.send(length_attr) * 
            ActiveSupport::Duration::PARTS_IN_SECONDS[self.send(units_attr).to_s.pluralize.to_sym], 
          { self.send(units_attr).pluralize.to_sym => self.send(length_attr) }
        )
      end if length_attr
    end

  end
end
