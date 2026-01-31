# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::CountryQuery do
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
      it 'selects country as label, count, and total_count' do
        sql = query.to_sql

        expect(sql).to include('country')
        expect(sql).to include('label')
        expect(sql).to include('count')
        expect(sql).to include('total_count')
      end

      it 'groups by country' do
        sql = query.to_sql

        expect(sql).to include('GROUP BY')
        expect(sql).to include('country')
      end

      it 'orders by count descending' do
        sql = query.to_sql

        expect(sql).to include('ORDER BY')
        expect(sql).to include('desc')
      end
    end

    context 'with visit data' do
      before do
        # Create visits with different countries
        # Each visit needs an associated event to be included in results
        3.times do
          visit = create(:ahoy_visit, country: 'United States', started_at: 1.day.ago)
          create(:ahoy_event, visit: visit, time: 1.day.ago)
        end

        2.times do
          visit = create(:ahoy_visit, country: 'Canada', started_at: 1.day.ago)
          create(:ahoy_event, visit: visit, time: 1.day.ago)
        end

        visit = create(:ahoy_visit, country: 'United Kingdom', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit, time: 1.day.ago)

        # Visit with nil country
        visit = create(:ahoy_visit, country: nil, started_at: 1.day.ago)
        create(:ahoy_event, visit: visit, time: 1.day.ago)
      end

      it 'returns countries ordered by count descending' do
        results = query.to_a

        expect(results.first.label).to eq('United States')
        expect(results.first.count).to eq(3)
      end

      it 'includes nil countries in results' do
        results = query.to_a

        labels = results.map(&:label)
        expect(labels).to include(nil)
      end

      it 'returns correct total_count across all results' do
        results = query.to_a

        # total_count is the sum of all counts (3 US + 2 Canada + 1 UK = 6 non-nil countries)
        # Note: The window function may not include the nil country group in the total
        expect(results.first.total_count.to_i).to eq(6)
      end

      it 'uses label alias for country' do
        results = query.to_a

        expect(results.first).to respond_to(:label)
        expect(results.first.label).to eq('United States')
      end

      it 'returns correct count for each country' do
        results = query.to_a

        us_result = results.find { |r| r.label == 'United States' }
        canada_result = results.find { |r| r.label == 'Canada' }
        uk_result = results.find { |r| r.label == 'United Kingdom' }
        nil_result = results.find { |r| r.label.nil? }

        expect(us_result.count).to eq(3)
        expect(canada_result.count).to eq(2)
        expect(uk_result.count).to eq(1)
        # count(country) returns 0 for NULL country values
        expect(nil_result.count).to eq(0)
      end
    end

    context 'with date filtering' do
      before do
        visit1 = create(:ahoy_visit, country: 'United States', started_at: 1.day.ago)
        create(:ahoy_event, visit: visit1, time: 1.day.ago)

        visit2 = create(:ahoy_visit, country: 'Germany', started_at: 60.days.ago)
        create(:ahoy_event, visit: visit2, time: 60.days.ago)
      end

      it 'only includes visits within the date range' do
        results = query.to_a

        labels = results.map(&:label)
        expect(labels).to include('United States')
        expect(labels).not_to include('Germany')
      end
    end
  end
end
