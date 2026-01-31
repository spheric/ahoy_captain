# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::EventQuery do
  describe '#build' do
    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d',
        controller: 'ahoy_captain/events'
      }
    end

    context 'without filters' do
      let(:params) { base_params }

      it 'returns a query object' do
        result = described_class.call(params)

        expect(result).to be_a(described_class)
      end

      it 'builds a valid SQL query' do
        result = described_class.call(params)

        expect { result.to_sql }.not_to raise_error
      end

      it 'queries the events table' do
        result = described_class.call(params)

        expect(result.to_sql).to include('ahoy_events')
      end
    end

    context 'with date range filtering' do
      let(:start_date) { 7.days.ago }
      let(:end_date) { Time.current }
      let(:params) { base_params.merge(start_date: start_date, end_date: end_date) }

      it 'filters by time' do
        result = described_class.call(params)

        expect(result.to_sql).to include('time')
      end
    end

    context 'with event name filter' do
      let(:params) { base_params.merge(q: { 'name_eq' => '$view' }) }

      it 'filters by event name' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('name')
        expect(sql).to include('$view')
      end
    end

    context 'with visit association filters' do
      let(:params) { base_params.merge(q: { 'browser_eq' => 'Chrome' }) }

      it 'joins visits table' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('ahoy_visits')
      end

      it 'filters by visit browser' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('browser')
        expect(sql).to include('Chrome')
      end
    end

    context 'with country filter via visit' do
      let(:params) { base_params.merge(q: { 'country_eq' => 'United States' }) }

      it 'filters by visit country' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('country')
        expect(sql).to include('United States')
      end
    end

    context 'with entry_page filter' do
      let(:params) do
        base_params.merge(
          q: { 'entry_page_eq' => '/home' },
          controller: 'ahoy_captain/entry_pages'
        )
      end

      it 'includes entry_pages in the query' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('entry_pages')
      end
    end

    context 'with exit_page filter' do
      let(:params) do
        base_params.merge(
          q: { 'exit_page_eq' => '/checkout' },
          controller: 'ahoy_captain/exit_pages'
        )
      end

      it 'includes exit_pages in the query' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('exit_pages')
      end
    end

    describe '#page_view' do
      let(:params) { base_params }

      it 'filters to page view events' do
        result = described_class.call(params).page_view
        sql = result.to_sql

        expect(sql).to include('$view')
      end

      it 'returns self for chaining' do
        result = described_class.call(params)

        expect(result.page_view).to eq(result)
      end
    end

    describe 'query execution' do
      let(:params) { base_params }
      let!(:visit) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:event) { create(:ahoy_event, visit: visit, time: 5.days.ago) }

      it 'returns events within the date range' do
        result = described_class.call(params)

        expect(result.to_a).to include(event)
      end

      context 'with events outside date range' do
        let!(:old_visit) { create(:ahoy_visit, started_at: 60.days.ago) }
        let!(:old_event) { create(:ahoy_event, visit: old_visit, time: 60.days.ago) }

        it 'excludes events outside the date range' do
          result = described_class.call(params)

          expect(result.to_a).not_to include(old_event)
        end
      end

      context 'with event name filter' do
        let!(:page_view_event) { create(:ahoy_event, :page_view, visit: visit, time: 5.days.ago) }
        let!(:custom_event) { create(:ahoy_event, :custom_event, event_name: 'button_click', visit: visit, time: 5.days.ago) }
        let(:params) { base_params.merge(q: { 'name_eq' => '$view' }) }

        it 'returns only matching events' do
          result = described_class.call(params)
          events = result.to_a

          expect(events).to include(page_view_event)
          expect(events).not_to include(custom_event)
        end
      end

      context 'with visit browser filter' do
        let!(:chrome_visit) { create(:ahoy_visit, browser: 'Chrome', started_at: 5.days.ago) }
        let!(:firefox_visit) { create(:ahoy_visit, browser: 'Firefox', started_at: 5.days.ago) }
        let!(:chrome_event) { create(:ahoy_event, visit: chrome_visit, time: 5.days.ago) }
        let!(:firefox_event) { create(:ahoy_event, visit: firefox_visit, time: 5.days.ago) }
        let(:params) { base_params.merge(q: { 'browser_eq' => 'Chrome' }) }

        it 'returns only events from matching visits' do
          result = described_class.call(params)
          events = result.to_a

          expect(events).to include(chrome_event)
          expect(events).not_to include(firefox_event)
        end
      end

      context 'with visit device_type filter' do
        let!(:desktop_visit) { create(:ahoy_visit, :desktop, started_at: 5.days.ago) }
        let!(:mobile_visit) { create(:ahoy_visit, :mobile, started_at: 5.days.ago) }
        let!(:desktop_event) { create(:ahoy_event, visit: desktop_visit, time: 5.days.ago) }
        let!(:mobile_event) { create(:ahoy_event, visit: mobile_visit, time: 5.days.ago) }
        let(:params) { base_params.merge(q: { 'device_type_eq' => 'Desktop' }) }

        it 'returns only events from desktop visits' do
          result = described_class.call(params)
          events = result.to_a

          expect(events).to include(desktop_event)
          expect(events).not_to include(mobile_event)
        end
      end

      context 'with page_view scope' do
        let!(:page_view) { create(:ahoy_event, :page_view, visit: visit, time: 5.days.ago) }
        let!(:custom) { create(:ahoy_event, :custom_event, event_name: 'click', visit: visit, time: 5.days.ago) }

        it 'returns only page view events' do
          result = described_class.call(params).page_view
          events = result.to_a

          expect(events).to include(page_view)
          expect(events).not_to include(custom)
        end
      end
    end

    describe 'delegation' do
      let(:params) { base_params }

      it 'delegates missing methods to the query' do
        result = described_class.call(params)

        expect(result).to respond_to(:where)
        expect(result).to respond_to(:order)
        expect(result).to respond_to(:limit)
      end

      it 'can chain additional queries' do
        result = described_class.call(params)

        expect { result.limit(10).to_sql }.not_to raise_error
      end
    end
  end
end
