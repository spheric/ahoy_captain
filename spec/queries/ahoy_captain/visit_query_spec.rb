# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::VisitQuery do
  describe '#build' do
    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d'
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

      it 'queries the visits table' do
        result = described_class.call(params)

        expect(result.to_sql).to include('ahoy_visits')
      end
    end

    context 'with date range filtering' do
      let(:start_date) { 7.days.ago }
      let(:end_date) { Time.current }
      let(:params) { base_params.merge(start_date: start_date, end_date: end_date) }

      it 'filters by started_at' do
        result = described_class.call(params)

        expect(result.to_sql).to include('started_at')
      end
    end

    context 'with visit attribute filters' do
      let(:params) { base_params.merge(q: { 'browser_eq' => 'Chrome' }) }

      it 'filters by browser' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('browser')
        expect(sql).to include('Chrome')
      end
    end

    context 'with country filter' do
      let(:params) { base_params.merge(q: { 'country_eq' => 'United States' }) }

      it 'filters by country' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('country')
        expect(sql).to include('United States')
      end
    end

    context 'with utm_source filter' do
      let(:params) { base_params.merge(q: { 'utm_source_eq' => 'google' }) }

      it 'filters by utm_source' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('utm_source')
        expect(sql).to include('google')
      end
    end

    context 'with event association filters' do
      let(:params) { base_params.merge(q: { 'name_eq' => '$view' }) }

      it 'joins events table' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('ahoy_events')
      end

      it 'filters by event name' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('name')
      end
    end

    context 'with referring_domain filter using ref_domain ransacker' do
      let(:params) { base_params.merge(q: { 'ref_domain_eq' => 'google.com' }) }

      it 'applies the ref_domain ransacker' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('referring_domain')
      end
    end

    describe '#is_a?' do
      let(:params) { base_params }

      it 'returns true for ActiveRecord::Relation' do
        result = described_class.call(params)

        expect(result.is_a?(ActiveRecord::Relation)).to be true
      end

      it 'returns false for other classes' do
        result = described_class.call(params)

        expect(result.is_a?(String)).to be false
      end
    end

    describe 'query execution' do
      let(:params) { base_params }
      let!(:visit) { create(:ahoy_visit, started_at: 5.days.ago) }
      let!(:event) { create(:ahoy_event, visit: visit, time: 5.days.ago) }

      it 'returns visits within the date range' do
        result = described_class.call(params)

        expect(result.to_a).to include(visit)
      end

      context 'with visits outside date range' do
        let!(:old_visit) { create(:ahoy_visit, started_at: 60.days.ago) }
        let!(:old_event) { create(:ahoy_event, visit: old_visit, time: 60.days.ago) }

        it 'excludes visits outside the date range' do
          result = described_class.call(params)

          expect(result.to_a).not_to include(old_visit)
        end
      end

      context 'with browser filter' do
        let!(:chrome_visit) { create(:ahoy_visit, browser: 'Chrome', started_at: 5.days.ago) }
        let!(:chrome_event) { create(:ahoy_event, visit: chrome_visit, time: 5.days.ago) }
        let!(:firefox_visit) { create(:ahoy_visit, browser: 'Firefox', started_at: 5.days.ago) }
        let!(:firefox_event) { create(:ahoy_event, visit: firefox_visit, time: 5.days.ago) }
        let(:params) { base_params.merge(q: { 'browser_eq' => 'Chrome' }) }

        it 'returns only matching visits' do
          result = described_class.call(params)
          visits = result.to_a

          expect(visits).to include(chrome_visit)
          expect(visits).not_to include(firefox_visit)
        end
      end

      context 'with device_type filter' do
        let!(:desktop_visit) { create(:ahoy_visit, :desktop, started_at: 5.days.ago) }
        let!(:desktop_event) { create(:ahoy_event, visit: desktop_visit, time: 5.days.ago) }
        let!(:mobile_visit) { create(:ahoy_visit, :mobile, started_at: 5.days.ago) }
        let!(:mobile_event) { create(:ahoy_event, visit: mobile_visit, time: 5.days.ago) }
        let(:params) { base_params.merge(q: { 'device_type_eq' => 'Desktop' }) }

        it 'returns only desktop visits' do
          result = described_class.call(params)
          visits = result.to_a

          expect(visits).to include(desktop_visit)
          expect(visits).not_to include(mobile_visit)
        end
      end

      context 'with utm filter' do
        let!(:utm_visit) { create(:ahoy_visit, :with_utm, utm_source: 'google', started_at: 5.days.ago) }
        let!(:utm_event) { create(:ahoy_event, visit: utm_visit, time: 5.days.ago) }
        let!(:no_utm_visit) { create(:ahoy_visit, utm_source: nil, started_at: 5.days.ago) }
        let!(:no_utm_event) { create(:ahoy_event, visit: no_utm_visit, time: 5.days.ago) }
        let(:params) { base_params.merge(q: { 'utm_source_eq' => 'google' }) }

        it 'returns only visits with matching utm_source' do
          result = described_class.call(params)
          visits = result.to_a

          expect(visits).to include(utm_visit)
          expect(visits).not_to include(no_utm_visit)
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
