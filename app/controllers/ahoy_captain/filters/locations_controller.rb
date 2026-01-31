module AhoyCaptain
  module Filters
    class LocationsController < BaseController
      ALLOWED_TYPES = %w[country region city].freeze

      def index
        type = ALLOWED_TYPES.include?(params[:type]) ? params[:type].to_sym : :country
        query = visit_query.all

        render json: query.select("distinct #{type}").where.not(type => nil).group(type).order(Arel.sql("count(*) desc")).limit(50).pluck(type).map { |city| serialize(city) }
      end
    end
  end
end
