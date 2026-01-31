module AhoyCaptain
  module Filters
    class UtmsController < BaseController
      ALLOWED_TYPES = %w[utm_source utm_medium utm_term utm_content utm_campaign].freeze

      def index
        type = ALLOWED_TYPES.include?(params[:type]) ? params[:type].to_sym : :utm_source
        query = visit_query.select(type, Arel.sql("count(#{type}) as total")).group(type).order(Arel.sql("count(#{type}) desc")).pluck(type).map { |city| serialize(city) }
        render json: query
      end
    end
  end
end
