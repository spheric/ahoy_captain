module AhoyCaptain
  class ExitPagesQuery < ApplicationQuery

    def build
      max_time_query = event_query.with_routes.select("max(#{AhoyCaptain.event.table_name}.time) as time").group("visit_id")
      event_query.with_routes.select(
        "#{AhoyCaptain.config.event[:url_column]} as url",
        "count(#{AhoyCaptain.config.event[:url_column]}) as count",
        "sum(count(#{AhoyCaptain.config.event[:url_column]})) over() as total_count"
      )
                 .where(time: max_time_query)
                 .group(AhoyCaptain.config.event[:url_column])
                 .order(Arel.sql "count(#{AhoyCaptain.config.event[:url_column]}) desc")

    end


  end
end
