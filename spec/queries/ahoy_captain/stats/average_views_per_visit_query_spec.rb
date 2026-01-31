# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::AverageViewsPerVisitQuery do
  describe 'inheritance' do
    it 'inherits from BaseQuery' do
      expect(described_class.superclass).to eq(AhoyCaptain::Stats::BaseQuery)
    end
  end

  describe '.cast_type' do
    it 'returns nil' do
      type = described_class.cast_type(:count)

      expect(type).to be_nil
    end
  end

  describe '.cast_value' do
    it 'converts value to integer' do
      result = described_class.cast_value(nil, '42')

      expect(result).to eq(42)
    end

    it 'converts float to integer' do
      result = described_class.cast_value(nil, 3.7)

      expect(result).to eq(3)
    end

    it 'returns 0 for nil' do
      result = described_class.cast_value(nil, nil)

      expect(result).to eq(0)
    end
  end

  describe '#build' do
    subject(:query) { described_class.new(params, nil) }

    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d',
        controller: 'ahoy_captain/stats/average_views_per_visit'
      }
    end
    let(:params) { base_params }

    it 'returns a query object' do
      result = query.send(:call)

      expect(result).to be_a(described_class)
    end

    it 'generates SQL that groups by visit_id' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('visit_id')
      expect(sql).to include('count')
    end

    context 'with page view events' do
      let!(:visit1) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:visit1_pageview1) { create(:ahoy_event, :page_view, visit: visit1, time: 5.days.ago) }
      let!(:visit1_pageview2) { create(:ahoy_event, :page_view, visit: visit1, time: 5.days.ago + 1.minute) }

      let!(:visit2) { create(:ahoy_visit, started_at: 4.days.ago) }
      let!(:visit2_pageview1) { create(:ahoy_event, :page_view, visit: visit2, time: 4.days.ago) }
      let!(:visit2_pageview2) { create(:ahoy_event, :page_view, visit: visit2, time: 4.days.ago + 1.minute) }
      let!(:visit2_pageview3) { create(:ahoy_event, :page_view, visit: visit2, time: 4.days.ago + 2.minutes) }
      let!(:visit2_pageview4) { create(:ahoy_event, :page_view, visit: visit2, time: 4.days.ago + 3.minutes) }

      it 'returns counts for each visit' do
        result = query.send(:call)
        records = result.to_a

        counts = records.map { |r| r.count.to_i }.sort
        expect(counts).to eq([2, 4])
      end
    end

    context 'with only custom events' do
      let!(:visit) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:custom_event) { create(:ahoy_event, :custom_event, event_name: 'button_click', visit: visit, time: 5.days.ago) }

      it 'returns empty result' do
        result = query.send(:call)
        records = result.to_a

        expect(records).to be_empty
      end
    end

    context 'with events outside the date range' do
      let!(:old_visit) { create(:ahoy_visit, started_at: 60.days.ago) }
      let!(:old_pageview) { create(:ahoy_event, :page_view, visit: old_visit, time: 60.days.ago) }
      let!(:recent_visit) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:recent_pageview) { create(:ahoy_event, :page_view, visit: recent_visit, time: 5.days.ago) }

      it 'only counts events within the date range' do
        result = query.send(:call)
        records = result.to_a

        expect(records.size).to eq(1)
        expect(records.first.count.to_i).to eq(1)
      end
    end
  end
end
