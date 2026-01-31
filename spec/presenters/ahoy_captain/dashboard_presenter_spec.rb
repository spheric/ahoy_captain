# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::DashboardPresenter do
  subject(:presenter) { described_class.new(params) }

  let(:base_params) do
    ActionController::Parameters.new({
      period: '30d',
      comparison: 'false',
      controller: 'ahoy_captain/dashboard'
    }).permit!
  end

  let(:params) { base_params }

  describe '#initialize' do
    it 'stores params' do
      expect(presenter.params).to eq(params)
    end
  end

  describe 'included modules' do
    it 'includes Rangeable' do
      expect(described_class.ancestors).to include(AhoyCaptain::Rangeable)
    end

    it 'includes RangeOptions' do
      expect(described_class.ancestors).to include(AhoyCaptain::RangeOptions)
    end

    it 'includes CompareMode' do
      expect(described_class.ancestors).to include(AhoyCaptain::CompareMode)
    end
  end

  describe '#period' do
    context 'when period param is present' do
      let(:params) { base_params.merge(period: '7d') }

      it 'returns the period from params' do
        expect(presenter.period).to eq('7d')
      end
    end

    context 'when period param is nil' do
      let(:params) { ActionController::Parameters.new({ controller: 'ahoy_captain/dashboard' }).permit! }

      it 'returns the default range from config' do
        expect(presenter.period).to eq(AhoyCaptain.config.ranges.default)
      end
    end
  end

  describe '#unique_visitors' do
    let!(:visit1) { create(:ahoy_visit, started_at: 1.day.ago) }
    let!(:visit2) { create(:ahoy_visit, started_at: 2.days.ago) }
    let!(:visit3) { create(:ahoy_visit, visitor_token: visit1.visitor_token, started_at: 3.days.ago) }

    it 'returns the count of unique visitors' do
      count = presenter.unique_visitors
      expect(count).to be_a(Integer)
    end

    it 'calls UniqueVisitorsQuery' do
      expect(AhoyCaptain::Stats::UniqueVisitorsQuery).to receive(:call).with(params).and_call_original
      presenter.unique_visitors
    end
  end

  describe '#total_visits' do
    let!(:visit1) { create(:ahoy_visit, started_at: 1.day.ago) }
    let!(:visit2) { create(:ahoy_visit, started_at: 2.days.ago) }

    it 'returns the count of total visits' do
      count = presenter.total_visits
      expect(count).to be_a(Integer)
    end

    it 'calls TotalVisitorsQuery' do
      expect(AhoyCaptain::Stats::TotalVisitorsQuery).to receive(:call).with(params).and_call_original
      presenter.total_visits
    end
  end

  describe '#total_pageviews' do
    let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
    let!(:event1) { create(:ahoy_event, :page_view, visit: visit, time: 1.day.ago) }
    let!(:event2) { create(:ahoy_event, :page_view, visit: visit, time: 1.day.ago) }

    it 'returns the count of total pageviews' do
      count = presenter.total_pageviews
      expect(count).to be_a(Integer)
    end

    it 'calls TotalPageviewsQuery' do
      expect(AhoyCaptain::Stats::TotalPageviewsQuery).to receive(:call).with(params).and_call_original
      presenter.total_pageviews
    end
  end

  describe '#views_per_visit' do
    let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
    let!(:event1) { create(:ahoy_event, :page_view, visit: visit, time: 1.day.ago) }
    let!(:event2) { create(:ahoy_event, :page_view, visit: visit, time: 1.day.ago) }

    it 'returns the average views per visit' do
      result = presenter.views_per_visit
      expect(result).to be_a(Numeric).or be_nil
    end

    it 'calls AverageViewsPerVisitQuery' do
      expect(AhoyCaptain::Stats::AverageViewsPerVisitQuery).to receive(:call).with(params).and_call_original
      presenter.views_per_visit
    end
  end

  describe '#bounce_rate' do
    context 'without comparison mode' do
      let(:params) { base_params.merge(comparison: 'false') }

      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
      let!(:event) { create(:ahoy_event, :page_view, visit: visit, time: 1.day.ago) }

      it 'returns a numeric bounce rate or zero' do
        result = presenter.bounce_rate
        expect(result).to be_a(Numeric)
      end

      it 'calls BounceRatesQuery' do
        expect(AhoyCaptain::Stats::BounceRatesQuery).to receive(:call).with(params).and_call_original
        presenter.bounce_rate
      end
    end

    context 'with comparison mode' do
      let(:params) { base_params.merge(comparison: 'true') }

      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
      let!(:event) { create(:ahoy_event, :page_view, visit: visit, time: 1.day.ago) }

      it 'returns a Comparison object' do
        result = presenter.bounce_rate
        expect(result).to be_a(AhoyCaptain::ComparableQuery::Comparison)
      end
    end
  end

  describe '#visit_duration' do
    context 'without comparison mode' do
      let(:params) { base_params.merge(comparison: 'false') }

      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
      let!(:event) { create(:ahoy_event, :page_view, visit: visit, time: 1.day.ago + 30.seconds) }

      it 'returns average visit duration' do
        result = presenter.visit_duration
        expect(result).not_to be_nil
      end

      it 'calls AverageVisitDurationQuery' do
        expect(AhoyCaptain::Stats::AverageVisitDurationQuery).to receive(:call).with(params).and_call_original
        presenter.visit_duration
      end
    end

    context 'with comparison mode' do
      let(:params) { base_params.merge(comparison: 'true') }

      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
      let!(:event) { create(:ahoy_event, :page_view, visit: visit, time: 1.day.ago + 30.seconds) }

      it 'returns a Comparison object' do
        result = presenter.visit_duration
        expect(result).to be_a(AhoyCaptain::ComparableQuery::Comparison)
      end
    end
  end

  describe '#compare_mode?' do
    context 'when comparison param is false' do
      let(:params) { base_params.merge(comparison: 'false') }

      it 'returns false' do
        expect(presenter.send(:compare_mode?)).to be false
      end
    end

    context 'when comparison param is not false' do
      let(:params) { base_params.merge(comparison: 'true') }

      it 'returns true' do
        expect(presenter.send(:compare_mode?)).to be true
      end
    end

    context 'when comparison param is nil' do
      let(:params) { ActionController::Parameters.new({ period: '30d', controller: 'ahoy_captain/dashboard' }).permit! }

      it 'returns true (default behavior)' do
        expect(presenter.send(:compare_mode?)).to be true
      end
    end
  end
end
