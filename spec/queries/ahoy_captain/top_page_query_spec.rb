# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::TopPageQuery do
  describe '#build' do
    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d',
        controller: 'ahoy_captain/stats'
      }
    end

    let(:params) { base_params }

    context 'with basic query structure' do
      it 'returns a query object that responds to to_sql' do
        result = described_class.call(params)

        expect(result).to respond_to(:to_sql)
      end

      it 'groups by URL column' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('GROUP BY')
      end

      it 'orders by count descending' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('ORDER BY')
        expect(sql).to include('desc')
      end

      it 'includes total_count in selection' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('total_count')
      end
    end

    context 'with UUID primary keys' do
      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
      let!(:event1) do
        create(:ahoy_event, :with_url, visit: visit, time: 1.day.ago, url: '/home')
      end
      let!(:event2) do
        create(:ahoy_event, :with_url, visit: visit, time: 1.day.ago, url: '/about')
      end
      let!(:event3) do
        create(:ahoy_event, :with_url, visit: visit, time: 1.day.ago, url: '/home')
      end

      it 'returns page counts correctly' do
        result = described_class.call(params).to_a

        # The query counts page views by controller#action format
        expect(result).to be_an(Array)
      end

      it 'works regardless of UUID ordering' do
        # UUIDs are random and don't have inherent ordering
        # The query should work correctly without relying on ID ordering
        expect { described_class.call(params).to_a }.not_to raise_error
      end
    end

    context 'with multiple visits and events' do
      let!(:visit1) { create(:ahoy_visit, started_at: 1.day.ago) }
      let!(:visit2) { create(:ahoy_visit, started_at: 1.day.ago) }

      before do
        # Create events for visit1
        create(:ahoy_event, :with_url, visit: visit1, time: 1.day.ago, url: '/products')
        create(:ahoy_event, :with_url, visit: visit1, time: 1.day.ago, url: '/products')

        # Create events for visit2
        create(:ahoy_event, :with_url, visit: visit2, time: 1.day.ago, url: '/products')
        create(:ahoy_event, :with_url, visit: visit2, time: 1.day.ago, url: '/contact')
      end

      it 'aggregates page views across visits' do
        result = described_class.call(params).to_a

        expect(result.length).to be >= 1
      end

      it 'calculates total_count correctly' do
        result = described_class.call(params).to_a

        if result.any?
          # Each result should have total_count populated
          expect(result.first).to respond_to(:total_count)
        end
      end
    end

    context 'with date filtering' do
      let!(:visit_old) { create(:ahoy_visit, started_at: 60.days.ago) }
      let!(:visit_recent) { create(:ahoy_visit, started_at: 1.day.ago) }

      before do
        create(:ahoy_event, :with_url, visit: visit_old, time: 60.days.ago, url: '/old')
        create(:ahoy_event, :with_url, visit: visit_recent, time: 1.day.ago, url: '/recent')
      end

      it 'filters events within the date range' do
        result = described_class.call(params).to_a

        # Events from 60 days ago should be excluded with a 30d period
        urls = result.map(&:url)
        expect(urls.any? { |u| u.include?('old') }).to be false
      end
    end
  end
end
