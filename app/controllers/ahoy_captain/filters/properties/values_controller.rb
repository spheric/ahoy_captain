module AhoyCaptain
  module Filters
    module Properties
      class ValuesController < BaseController
        def index
          return render json: [] if params[:q].blank?

          param_key = params[:q].to_unsafe_h.detect { |k,v| k.ends_with?("_i_cont") && k.starts_with?("properties.") }&.first
          return render json: [] if param_key.nil?

          key = param_key.delete_prefix("properties.").delete_suffix("_i_cont")
          # Sanitize key to prevent SQL injection - only allow alphanumeric and underscores
          return render json: [] unless key.match?(/\A[a-zA-Z_][a-zA-Z0-9_]*\z/)

          sanitized_key = ActiveRecord::Base.connection.quote_column_name(key)
          query = event_query.all.distinct.select(Arel.sql("properties->>#{ActiveRecord::Base.connection.quote(key)}")).pluck(Arel.sql("properties->>#{ActiveRecord::Base.connection.quote(key)}"))

          render json: query.compact.map { |element| serialize(element) }
        end
      end
    end
  end
end
