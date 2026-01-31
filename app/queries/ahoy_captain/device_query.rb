module AhoyCaptain
  class DeviceQuery < ApplicationQuery
    ALLOWED_DEVICE_TYPES = %w[browser os device_type].freeze

    def build
      device_type = ALLOWED_DEVICE_TYPES.include?(params[:devices_type]) ? params[:devices_type] : 'device_type'

      visit_query
        .select("#{device_type} as label", "count(#{device_type}) as count", "sum(count(#{device_type})) over() as total_count")
        .group(device_type)
        .order("count(#{device_type}) desc")
    end
  end
end
