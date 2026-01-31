# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::RegionQuery do
  describe '#build' do
    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d'
      }
    end

    let(:params) { base_params }

    subject(:query) { described_class.call(params) }

    context 'SQL structure' do
      it 'selects region, country, count, and total_count' do
        sql = query.to_sql

        expect(sql).to include('region')
        expect(sql).to include('country')
        expect(sql).to include('count')
        expect(sql).to include('total_count')
      end

      it 'groups by region and country' do
        sql = query.to_sql

        expect(sql).to include('GROUP BY')
        expect(sql).to include('region')
        expect(sql).to include('country')
      end

      it 'excludes nil regions' do
        sql = query.to_sql

        expect(sql).to include('"region" IS NOT NULL')
      end

      it 'orders by count descending' do
        sql = query.to_sql

        expect(sql).to include('ORDER BY')
        expect(sql).to include('desc')
      end
    end

    context 'with visit data' do
      before do
        # Create visits with different regions
        # Each visit needs an associated event to be included in results
        3.times do
          visit = create(:ahoy_visit, region: 'California', country: 'United States', started_at: 1.day.ago)
          create(:ahoy_event, visit: visit, time: 1.day.ago)
        end

        2.times do
          visit = create(:ahoy_visit, region: 'New York', country: 'United States', started_at: 1.day.ago)
          create(:ahoy_event, visit: visit, time: 1.day.ago)
        end

        visit = create(:ahoy_visit, region: 'Texas', country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit, time: 1.day.ago)

        # Visit with nil region should be excluded
        visit = create(:ahoy_visit, region: nil, country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit, time: 1.day.ago)
      end

      it 'returns regions ordered by count descending' do
        results = query.to_a

        expect(results.first.region).to eq('California')
        expect(results.first.count).to eq(3)
      end

      it 'excludes visits with nil regions' do
        results = query.to_a

        regions = results.map(&:region)
        expect(regions).not_to include(nil)
      end

      it 'returns correct total_count across all results' do
        results = query.to_a

        # total_count should be 6 (all non-nil region visits)
        expect(results.first.total_count).to eq(6)
      end

      it 'includes country in results' do
        results = query.to_a

        expect(results.first.country).to eq('United States')
      end

      it 'groups regions by country' do
        # Create same region name in different countries
        visit1 = create(:ahoy_visit, region: 'Ontario', country: 'Canada', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit1, time: 1.day.ago)
        visit2 = create(:ahoy_visit, region: 'Ontario', country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit2, time: 1.day.ago)

        results = query.to_a

        ontario_results = results.select { |r| r.region == 'Ontario' }
        expect(ontario_results.length).to eq(2)
      end
    end

    context 'with date filtering' do
      before do
        visit1 = create(:ahoy_visit, region: 'California', country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit1, time: 1.day.ago)

        visit2 = create(:ahoy_visit, region: 'Texas', country: 'United States', started_at: 60.days.ago)
        create(:ahoy_event, visit: visit2, time: 60.days.ago)
      end

      it 'only includes visits within the date range' do
        results = query.to_a

        regions = results.map(&:region)
        expect(regions).to include('California')
        expect(regions).not_to include('Texas')
      end
    end
  end
end
