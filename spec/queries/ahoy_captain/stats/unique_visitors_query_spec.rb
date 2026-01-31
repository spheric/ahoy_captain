# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::UniqueVisitorsQuery do
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
        controller: 'ahoy_captain/stats/unique_visitors'
      }
    end
    let(:params) { base_params }

    it 'returns a query object' do
      result = query.send(:call)

      expect(result).to be_a(described_class)
    end

    it 'selects distinct visitor_token' do
      result = query.send(:call)

      expect(result.to_sql).to include('DISTINCT')
      expect(result.to_sql).to include('visitor_token')
    end

    context 'with visits in the database' do
      let!(:visit1) { create(:ahoy_visit, visitor_token: 'visitor_1', started_at: 5.days.ago) }
      let!(:event1) { create(:ahoy_event, :page_view, visit: visit1, time: 5.days.ago) }
      let!(:visit2) { create(:ahoy_visit, visitor_token: 'visitor_2', started_at: 5.days.ago) }
      let!(:event2) { create(:ahoy_event, :page_view, visit: visit2, time: 5.days.ago) }
      let!(:visit3) { create(:ahoy_visit, visitor_token: 'visitor_1', started_at: 3.days.ago) }
      let!(:event3) { create(:ahoy_event, :page_view, visit: visit3, time: 3.days.ago) }

      it 'counts unique visitors correctly' do
        result = query.send(:call)

        expect(result.count).to eq(2)
      end
    end

    context 'with visits outside the date range' do
      let!(:old_visit) { create(:ahoy_visit, visitor_token: 'old_visitor', started_at: 60.days.ago) }
      let!(:old_event) { create(:ahoy_event, :page_view, visit: old_visit, time: 60.days.ago) }
      let!(:recent_visit) { create(:ahoy_visit, visitor_token: 'recent_visitor', started_at: 5.days.ago) }
      let!(:recent_event) { create(:ahoy_event, :page_view, visit: recent_visit, time: 5.days.ago) }

      it 'only counts visitors within the date range' do
        result = query.send(:call)

        expect(result.count).to eq(1)
      end
    end
  end
end
