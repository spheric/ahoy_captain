# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::ViewsPerVisitQuery do
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
        controller: 'ahoy_captain/stats/views_per_visit'
      }
    end
    let(:params) { base_params }

    it 'returns a query object' do
      result = query.send(:call)

      expect(result).to be_a(described_class)
    end

    it 'generates SQL with views_per_visit calculation' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('views_per_visit')
    end

    context 'with visits that have page views' do
      let(:visit_start) { 5.days.ago }
      let!(:visit) { create(:ahoy_visit, started_at: visit_start) }
      let!(:pageview1) { create(:ahoy_event, :page_view, visit: visit, time: visit_start) }
      let!(:pageview2) { create(:ahoy_event, :page_view, visit: visit, time: visit_start + 1.minute) }
      let!(:pageview3) { create(:ahoy_event, :page_view, visit: visit, time: visit_start + 2.minutes) }

      it 'calculates views per visit' do
        result = query.send(:call)
        records = result.to_a

        expect(records).not_to be_empty
        expect(records.first.views_per_visit).to eq(3)
      end
    end

    context 'with multiple visits' do
      let(:visit1_start) { 5.days.ago }
      let(:visit2_start) { 4.days.ago }

      let!(:visit1) { create(:ahoy_visit, started_at: visit1_start) }
      let!(:visit1_pageview1) { create(:ahoy_event, :page_view, visit: visit1, time: visit1_start) }
      let!(:visit1_pageview2) { create(:ahoy_event, :page_view, visit: visit1, time: visit1_start + 1.minute) }

      let!(:visit2) { create(:ahoy_visit, started_at: visit2_start) }
      let!(:visit2_pageview1) { create(:ahoy_event, :page_view, visit: visit2, time: visit2_start) }

      it 'returns views per visit for each visit' do
        result = query.send(:call)
        records = result.to_a

        expect(records.size).to eq(2)
        views = records.map(&:views_per_visit).sort
        expect(views).to eq([1, 2])
      end
    end

    context 'with custom events mixed in' do
      let(:visit_start) { 5.days.ago }
      let!(:visit) { create(:ahoy_visit, started_at: visit_start) }
      let!(:pageview) { create(:ahoy_event, :page_view, visit: visit, time: visit_start) }
      let!(:custom_event) { create(:ahoy_event, :custom_event, event_name: 'button_click', visit: visit, time: visit_start + 1.minute) }

      it 'only counts page view events' do
        result = query.send(:call)
        records = result.to_a

        expect(records).not_to be_empty
        expect(records.first.views_per_visit).to eq(1)
      end
    end
  end
end
