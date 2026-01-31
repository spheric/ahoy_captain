# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::TotalPageviewsQuery do
  describe 'inheritance' do
    it 'inherits from BaseQuery' do
      expect(described_class.superclass).to eq(AhoyCaptain::Stats::BaseQuery)
    end
  end

  describe '#build' do
    subject(:query) { described_class.new(params, nil) }

    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d',
        controller: 'ahoy_captain/stats/total_pageviews'
      }
    end
    let(:params) { base_params }

    it 'returns a query object' do
      result = query.send(:call)

      expect(result).to be_a(described_class)
    end

    context 'with page view events' do
      let!(:visit) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:pageview1) { create(:ahoy_event, :page_view, visit: visit, time: 5.days.ago) }
      let!(:pageview2) { create(:ahoy_event, :page_view, visit: visit, time: 5.days.ago + 1.minute) }
      let!(:pageview3) { create(:ahoy_event, :page_view, visit: visit, time: 5.days.ago + 2.minutes) }

      it 'counts all page view events' do
        result = query.send(:call)

        expect(result.count).to eq(3)
      end
    end

    context 'with mixed event types' do
      let!(:visit) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:pageview) { create(:ahoy_event, :page_view, visit: visit, time: 5.days.ago) }
      let!(:custom_event) { create(:ahoy_event, :custom_event, event_name: 'button_click', visit: visit, time: 5.days.ago) }

      it 'only counts page view events' do
        result = query.send(:call)

        expect(result.count).to eq(1)
      end
    end

    context 'with events outside the date range' do
      let!(:old_visit) { create(:ahoy_visit, started_at: 60.days.ago) }
      let!(:old_pageview) { create(:ahoy_event, :page_view, visit: old_visit, time: 60.days.ago) }
      let!(:recent_visit) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:recent_pageview) { create(:ahoy_event, :page_view, visit: recent_visit, time: 5.days.ago) }

      it 'only counts page views within the date range' do
        result = query.send(:call)

        expect(result.count).to eq(1)
      end
    end
  end
end
