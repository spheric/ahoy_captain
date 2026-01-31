# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::BounceRatesQuery do
  describe 'inheritance' do
    it 'inherits from BaseQuery' do
      expect(described_class.superclass).to eq(AhoyCaptain::Stats::BaseQuery)
    end
  end

  describe '.cast_type' do
    it 'returns decimal type' do
      type = described_class.cast_type(:bounce_rate)

      expect(type).to be_a(ActiveRecord::Type::Decimal)
    end
  end

  describe '.cast_value' do
    it 'returns 0 for blank values' do
      result = described_class.cast_value(nil, nil)

      expect(result).to eq(0.to_d)
    end

    it 'returns 0 for empty string' do
      result = described_class.cast_value(nil, '')

      expect(result).to eq(0.to_d)
    end

    it 'rounds to 2 decimal places' do
      type = ActiveRecord::Type.lookup(:decimal)
      result = described_class.cast_value(type, '33.3333')

      expect(result).to eq(33.33.to_d)
    end
  end

  describe '#build' do
    subject(:query) { described_class.new(params, nil) }

    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d',
        controller: 'ahoy_captain/stats/bounce_rates'
      }
    end
    let(:params) { base_params }

    it 'returns a query object' do
      result = query.send(:call)

      expect(result).to be_a(described_class)
    end

    it 'generates SQL with bounce rate calculation' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('bounce_rate')
    end

    context 'with bounced visits (single event)' do
      let(:visit_date) { 5.days.ago.beginning_of_day }
      let!(:bounced_visit) { create(:ahoy_visit, started_at: visit_date) }
      let!(:single_event) { create(:ahoy_event, :page_view, visit: bounced_visit, time: visit_date) }

      let!(:non_bounced_visit) { create(:ahoy_visit, started_at: visit_date) }
      let!(:event1) { create(:ahoy_event, :page_view, visit: non_bounced_visit, time: visit_date) }
      let!(:event2) { create(:ahoy_event, :page_view, visit: non_bounced_visit, time: visit_date + 5.minutes) }

      it 'returns records with bounce rate' do
        result = query.send(:call)
        records = result.to_a

        expect(records).not_to be_empty
        bounce_rate = records.first&.bounce_rate
        expect(bounce_rate).to be_present
      end

      it 'calculates a bounce rate between 0 and 100' do
        result = query.send(:call)
        records = result.to_a

        bounce_rate = records.first&.bounce_rate&.to_f
        expect(bounce_rate).to be >= 0
        expect(bounce_rate).to be <= 100
      end
    end

    context 'with all bounced visits' do
      let(:visit_date) { 5.days.ago.beginning_of_day }
      let!(:visit1) { create(:ahoy_visit, started_at: visit_date) }
      let!(:event1) { create(:ahoy_event, :page_view, visit: visit1, time: visit_date) }
      let!(:visit2) { create(:ahoy_visit, started_at: visit_date) }
      let!(:event2) { create(:ahoy_event, :page_view, visit: visit2, time: visit_date) }

      it 'returns 100% bounce rate' do
        result = query.send(:call)
        records = result.to_a

        expect(records).not_to be_empty
        bounce_rate = records.first&.bounce_rate
        expect(bounce_rate).to be_present
        expect(bounce_rate.to_f).to eq(100.0)
      end
    end

    context 'with no bounced visits' do
      let(:visit_date) { 5.days.ago.beginning_of_day }
      let!(:visit) { create(:ahoy_visit, started_at: visit_date) }
      let!(:event1) { create(:ahoy_event, :page_view, visit: visit, time: visit_date) }
      let!(:event2) { create(:ahoy_event, :page_view, visit: visit, time: visit_date + 5.minutes) }

      it 'returns empty result when no single page visits exist' do
        result = query.send(:call)
        records = result.to_a

        # The query uses a JOIN with single_page_visits, so when there are no bounces,
        # the result is empty. This is expected behavior.
        expect(records).to be_empty
      end
    end
  end
end
