require 'active_support'
require 'active_support/time'
class WaktuSubuh
  attr_accessor :morning_hours,:late_morning_hours

  def initialize(options={})
    @morning_hours = options[:morning_hours] || [6,7,8]
    @late_morning_hours = [10,11]
  end

  def morning_zone(hour_in_utc=0)
    zone = []
    morning_hours.each do |hour|
      if hour_in_utc > hour
        zona = -(hour_in_utc - hour)
        zona = 24 - hour_in_utc + hour if zona.abs >= 12
        zone << zona
      else
        zona = hour - hour_in_utc
        zona = -(zona - 12) if zona >= 12
        zone << zona
      end
    end
    zone
  end
  def late_morning_zone(hour_in_utc=0)
    zone = []
    late_morning_hours.each do |hour|
      if hour_in_utc > hour
        zona = -(hour_in_utc - hour)
        zona = 24 - hour_in_utc + hour if zona.abs >= 12
        zone << zona
      else
        zona = hour - hour_in_utc
        zona = -(zona - 12) if zona >= 12
        zone << zona
      end
    end
    zone
  end

  class << self
    def build_time_zone_list(method, offset = ENV['OFFSET'])
      zona = []
      if offset
        offset = if offset.to_s.match(/(\+|-)?(\d+):(\d+)/)
          sign = $1 == '-' ? -1 : 1
          hours, minutes = $2.to_f, $3.to_f
          ((hours * 3600) + (minutes.to_f * 60)) * sign
        elsif offset.to_f.abs <= 13
          offset.to_f * 3600
        else
          offset.to_f
        end
      end
      ActiveSupport::TimeZone.__send__(method).each do |zone|
        if offset.nil? || offset == zone.utc_offset
          zona << zone.name
        end
      end
      zona
    end
  end
end