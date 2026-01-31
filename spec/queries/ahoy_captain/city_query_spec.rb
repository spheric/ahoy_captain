# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::CityQuery do
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
      it 'selects city, country, count, and total_count' do
        sql = query.to_sql

        expect(sql).to include('city')
        expect(sql).to include('country')
        expect(sql).to include('count')
        expect(sql).to include('total_count')
      end

      it 'groups by city, region, and country' do
        sql = query.to_sql

        expect(sql).to include('GROUP BY')
        expect(sql).to include('city')
        expect(sql).to include('region')
        expect(sql).to include('country')
      end

      it 'excludes nil cities' do
        sql = query.to_sql

        expect(sql).to include('"city" IS NOT NULL')
      end

      it 'orders by count descending' do
        sql = query.to_sql

        expect(sql).to include('ORDER BY')
        expect(sql).to include('desc')
      end
    end

    context 'with visit data' do
      before do
        # Create visits with different cities in the same region/country
        # Each visit needs an associated event to be included in results
        3.times do
          visit = create(:ahoy_visit, city: 'San Francisco', region: 'California', country: 'United States', started_at: 1.day.ago)
          create(:ahoy_event, visit: visit, time: 1.day.ago)
        end

        2.times do
          visit = create(:ahoy_visit, city: 'Los Angeles', region: 'California', country: 'United States', started_at: 1.day.ago)
          create(:ahoy_event, visit: visit, time: 1.day.ago)
        end

        visit = create(:ahoy_visit, city: 'New York', region: 'New York', country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit, time: 1.day.ago)

        # Visit with nil city should be excluded
        visit = create(:ahoy_visit, city: nil, region: 'Texas', country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit, time: 1.day.ago)
      end

      it 'returns cities ordered by count descending' do
        results = query.to_a

        expect(results.first.city).to eq('San Francisco')
        expect(results.first.count).to eq(3)
      end

      it 'excludes visits with nil cities' do
        results = query.to_a

        cities = results.map(&:city)
        expect(cities).not_to include(nil)
      end

      it 'returns correct total_count across all results' do
        results = query.to_a

        # total_count should be 6 (all non-nil city visits)
        expect(results.first.total_count).to eq(6)
      end

      it 'includes country in results' do
        results = query.to_a

        expect(results.first.country).to eq('United States')
      end

      it 'groups cities by region and country' do
        # Create same city name in different regions
        visit1 = create(:ahoy_visit, city: 'Springfield', region: 'Illinois', country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit1, time: 1.day.ago)
        visit2 = create(:ahoy_visit, city: 'Springfield', region: 'Massachusetts', country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit2, time: 1.day.ago)

        results = query.to_a

        springfield_results = results.select { |r| r.city == 'Springfield' }
        expect(springfield_results.length).to eq(2)
      end
    end

    context 'with date filtering' do
      before do
        visit1 = create(:ahoy_visit, city: 'San Francisco', region: 'California', country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit1, time: 1.day.ago)

        visit2 = create(:ahoy_visit, city: 'Los Angeles', region: 'California', country: 'United States', started_at: 60.days.ago)
        create(:ahoy_event, visit: visit2, time: 60.days.ago)
      end

      it 'only includes visits within the date range' do
        results = query.to_a

        cities = results.map(&:city)
        expect(cities).to include('San Francisco')
        expect(cities).not_to include('Los Angeles')
      end
    end
  end
end
