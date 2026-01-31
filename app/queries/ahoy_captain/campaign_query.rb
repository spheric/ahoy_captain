module AhoyCaptain
  class CampaignQuery < ApplicationQuery
    ALLOWED_CAMPAIGN_TYPES = %w[utm_source utm_medium utm_term utm_content utm_campaign].freeze

    def build
      campaign_type = ALLOWED_CAMPAIGN_TYPES.include?(params[:campaigns_type]) ? params[:campaigns_type] : 'utm_source'

      visit_query
        .select(
          "COALESCE(#{campaign_type}, 'Direct/None') as label",
          "count(COALESCE(#{campaign_type}, 'Direct/None')) as count",
          "sum(count(COALESCE(#{campaign_type}, 'Direct/None'))) OVER() as total_count"
        )
        .group("COALESCE(#{campaign_type}, 'Direct/None')")
        .order(Arel.sql("count(COALESCE(#{campaign_type}, 'Direct/None')) desc"))
    end
  end
end
