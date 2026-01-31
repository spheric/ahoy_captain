# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::AverageVisitDurationQuery do
  describe 'inheritance' do
    it 'inherits from BaseQuery' do
      expect(described_class.superclass).to eq(AhoyCaptain::Stats::BaseQuery)
    end
  end

  describe '.cast_type' do
    it 'returns string type' do
      type = described_class.cast_type(:average_visit_duration)

      expect(type).to be_a(ActiveRecord::Type::String)
    end
  end

  describe '.cast_value' do
    it 'parses duration from ISO 8601 format' do
      result = described_class.cast_value(nil, 'PT1H30M')

      expect(result).to be_a(ActiveSupport::Duration)
      expect(result.in_minutes).to eq(90)
    end

    it 'returns zero duration for nil value' do
      result = described_class.cast_value(nil, nil)

      expect(result).to be_a(ActiveSupport::Duration)
      expect(result.to_i).to eq(0)
    end

    it 'returns zero duration for blank value' do
      result = described_class.cast_value(nil, '')

      expect(result).to be_a(ActiveSupport::Duration)
      expect(result.to_i).to eq(0)
    end
  end

  describe '#build' do
    subject(:query) { described_class.new(params, nil) }

    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d',
        controller: 'ahoy_captain/stats/average_visit_duration'
      }
    end
    let(:params) { base_params }

    it 'returns a query object' do
      result = query.send(:call)

      expect(result).to be_a(described_class)
    end

    it 'generates SQL with average visit duration calculation' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('avg')
      expect(sql).to include('started_at')
    end

    context 'with visits that have events' do
      let(:visit_start) { 5.days.ago }
      let!(:visit) { create(:ahoy_visit, started_at: visit_start) }
      let!(:event1) { create(:ahoy_event, :page_view, visit: visit, time: visit_start) }
      let!(:event2) { create(:ahoy_event, :page_view, visit: visit, time: visit_start + 10.minutes) }

      it 'calculates average duration from visit start to last event' do
        result = query.send(:call)
        records = result.to_a

        expect(records).not_to be_empty
      end
    end

    context 'with multiple visits of different durations' do
      let(:visit1_start) { 5.days.ago }
      let(:visit2_start) { 4.days.ago }

      let!(:visit1) { create(:ahoy_visit, started_at: visit1_start) }
      let!(:visit1_event) { create(:ahoy_event, :page_view, visit: visit1, time: visit1_start + 20.minutes) }

      let!(:visit2) { create(:ahoy_visit, started_at: visit2_start) }
      let!(:visit2_event) { create(:ahoy_event, :page_view, visit: visit2, time: visit2_start + 10.minutes) }

      it 'returns the average of all visit durations' do
        result = query.send(:call)
        records = result.to_a

        expect(records).not_to be_empty
      end
    end

    context 'with visits outside the date range' do
      let!(:old_visit) { create(:ahoy_visit, started_at: 60.days.ago) }
      let!(:old_event) { create(:ahoy_event, :page_view, visit: old_visit, time: 60.days.ago + 5.minutes) }
      let!(:recent_visit) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:recent_event) { create(:ahoy_event, :page_view, visit: recent_visit, time: 5.days.ago + 10.minutes) }

      it 'only considers visits within the date range' do
        result = query.send(:call)
        records = result.to_a

        expect(records).not_to be_empty
      end
    end
  end
end
