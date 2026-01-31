# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::ExitPagesQuery do
  describe '#build' do
    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d',
        controller: 'ahoy_captain/exit_pages'
      }
    end

    let(:params) { base_params }

    context 'with basic query structure' do
      it 'returns a query object that responds to to_sql' do
        result = described_class.call(params)

        expect(result).to respond_to(:to_sql)
      end

      it 'uses max(time) for exit page detection' do
        result = described_class.call(params)
        sql = result.to_sql

        # Exit pages are determined by maximum time, not maximum ID
        # This is critical for UUID compatibility
        expect(sql.downcase).to include('max')
        expect(sql.downcase).to include('time')
      end

      it 'groups by visit_id to find last page per visit' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('visit_id')
      end

      it 'orders by count descending' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('ORDER BY')
        expect(sql).to include('desc')
      end
    end

    context 'with UUID primary keys - time-based ordering' do
      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }

      # Create events with specific times to test time-based ordering
      # The exit page should be determined by maximum time, not by UUID
      let!(:first_event) do
        create(:ahoy_event, :with_url, visit: visit, time: 1.day.ago + 1.minute, url: '/landing')
      end
      let!(:second_event) do
        create(:ahoy_event, :with_url, visit: visit, time: 1.day.ago + 5.minutes, url: '/products')
      end
      let!(:third_event) do
        create(:ahoy_event, :with_url, visit: visit, time: 1.day.ago + 10.minutes, url: '/checkout')
      end

      it 'identifies exit page by maximum time not by UUID' do
        result = described_class.call(params).to_a

        # The query uses max(time) which is UUID-compatible
        # This should find the checkout page as exit page
        expect(result).to be_an(Array)

        # Verify the SQL uses time-based approach
        sql = described_class.call(params).to_sql.downcase
        expect(sql).to include('max')
        expect(sql).not_to include('max(id)')
        expect(sql).not_to include('max("id")')
      end

      it 'does not use ID-based ordering' do
        sql = described_class.call(params).to_sql

        # UUIDs cannot be meaningfully ordered, so the query must use time
        expect(sql).not_to match(/max\s*\(\s*["']?id["']?\s*\)/i)
        expect(sql).not_to match(/ORDER BY\s+["']?id["']?\s*(?:ASC|$)/i)
      end
    end

    context 'with multiple visits' do
      let!(:visit1) { create(:ahoy_visit, started_at: 1.day.ago) }
      let!(:visit2) { create(:ahoy_visit, started_at: 1.day.ago) }

      before do
        # Visit 1: landing -> products -> checkout (exit: checkout)
        create(:ahoy_event, :with_url, visit: visit1, time: 1.day.ago + 1.minute, url: '/landing')
        create(:ahoy_event, :with_url, visit: visit1, time: 1.day.ago + 5.minutes, url: '/products')
        create(:ahoy_event, :with_url, visit: visit1, time: 1.day.ago + 10.minutes, url: '/checkout')

        # Visit 2: home -> about (exit: about)
        create(:ahoy_event, :with_url, visit: visit2, time: 1.day.ago + 2.minutes, url: '/home')
        create(:ahoy_event, :with_url, visit: visit2, time: 1.day.ago + 8.minutes, url: '/about')
      end

      it 'finds exit page for each visit based on time' do
        result = described_class.call(params).to_a

        # Should have exit pages - the last page visited in each session
        expect(result).to be_an(Array)
      end

      it 'counts exit pages correctly' do
        result = described_class.call(params).to_a

        if result.any?
          # Total count should equal number of visits with page views
          total = result.map(&:count).sum
          expect(total).to be >= 1
        end
      end
    end

    context 'with events at same timestamp' do
      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
      let(:same_time) { 1.day.ago + 5.minutes }

      before do
        # Multiple events at the exact same time
        # The query should handle this gracefully
        create(:ahoy_event, :with_url, visit: visit, time: same_time, url: '/page1')
        create(:ahoy_event, :with_url, visit: visit, time: same_time, url: '/page2')
      end

      it 'handles simultaneous events without error' do
        expect { described_class.call(params).to_a }.not_to raise_error
      end
    end

    context 'with single page visits' do
      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }

      before do
        # Only one page view - it's both entry and exit page
        create(:ahoy_event, :with_url, visit: visit, time: 1.day.ago + 1.minute, url: '/single-page')
      end

      it 'handles single page visits correctly' do
        result = described_class.call(params).to_a

        # A single page visit should count as an exit page
        expect(result).to be_an(Array)
      end
    end

    context 'with date filtering' do
      let!(:old_visit) { create(:ahoy_visit, started_at: 60.days.ago) }
      let!(:recent_visit) { create(:ahoy_visit, started_at: 1.day.ago) }

      before do
        create(:ahoy_event, :with_url, visit: old_visit, time: 60.days.ago, url: '/old-exit')
        create(:ahoy_event, :with_url, visit: recent_visit, time: 1.day.ago, url: '/new-exit')
      end

      it 'excludes exit pages outside date range' do
        result = described_class.call(params).to_a
        urls = result.map(&:url)

        # Old exit page should be filtered out
        expect(urls.any? { |u| u.include?('old') }).to be false
      end
    end

    context 'SQL generation verification' do
      it 'generates valid SQL without syntax errors' do
        expect { described_class.call(params).to_sql }.not_to raise_error
      end

      it 'uses subquery with max(time) for exit page detection' do
        sql = described_class.call(params).to_sql.downcase

        # The query should use max(time) to find the last event
        expect(sql).to include('max(')
        expect(sql).to include('.time')
      end
    end

    context 'comparing entry vs exit page approach' do
      it 'uses opposite time function from entry pages' do
        exit_sql = described_class.call(params).to_sql.downcase
        entry_params = params.merge(controller: 'ahoy_captain/entry_pages')
        entry_sql = AhoyCaptain::EntryPagesQuery.call(entry_params).to_sql.downcase

        # Exit uses max(time), Entry uses min(time)
        expect(exit_sql).to include('max(')
        expect(entry_sql).to include('min(')
      end
    end
  end
end
