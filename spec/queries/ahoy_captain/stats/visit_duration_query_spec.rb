# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::VisitDurationQuery do
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
        controller: 'ahoy_captain/stats/visit_duration'
      }
    end
    let(:params) { base_params }

    it 'returns a query object' do
      result = query.send(:call)

      expect(result).to be_a(described_class)
    end

    it 'generates SQL with duration calculation' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('duration')
    end

    it 'includes started_at in the result' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('started_at')
    end

    it 'joins with visits table' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('ahoy_visits')
      expect(sql).to include('inner join')
    end

    it 'groups by visit_id to calculate duration per visit' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('GROUP BY')
      expect(sql).to include('visit_id')
    end

    it 'uses max and min time to calculate duration' do
      result = query.send(:call)
      sql = result.to_sql

      expect(sql).to include('max')
      expect(sql).to include('min')
    end
  end
end
