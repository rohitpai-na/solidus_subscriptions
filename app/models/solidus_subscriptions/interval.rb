# This module is intended to be included into any active record
# modle which needs to be aware of how intervals and stored and
# calculated in the db.
#
# Base models must have the following fields: interval_length (integer) and interval_units (integer)
module SolidusSubscriptions
  module Interval
    def self.included(base)
      base.enum interval_units: {
        days: 0,
        weeks: 1,
        months: 2,
        years: 3
      }
    end

    # Calculates the number of seconds in the interval.
    #
    # @return [Integer] The number of seconds.
    def interval
      ActiveSupport::Duration.new(interval_length, { interval_units.pluralize.to_sym => interval_length })
    end
  end
end
