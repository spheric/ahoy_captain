# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::RangeOptions do
  let(:test_class) do
    Class.new do
      include AhoyCaptain::RangeOptions

      attr_accessor :params

      def initialize(params = {})
        @params = params
      end
    end
  end

  describe '#range' do
    subject(:instance) { test_class.new(params) }

    context 'with default period' do
      let(:params) { {} }

      it 'returns a RangeFromParams instance' do
        expect(instance.send(:range)).to be_a(AhoyCaptain::RangeFromParams)
      end

      it 'returns the default range' do
        range = instance.send(:range)
        expect(range.starts_at).to be_present
        expect(range.ends_at).to be_present
      end
    end

    context 'with a specific period' do
      let(:params) { { period: '7d' } }

      it 'returns a RangeFromParams instance' do
        expect(instance.send(:range)).to be_a(AhoyCaptain::RangeFromParams)
      end

      it 'returns the correct range for 7d' do
        range = instance.send(:range)
        expect(range.starts_at).to be_within(1.second).of(7.days.ago)
      end
    end

    context 'with custom start and end dates' do
      let(:start_date) { 2.weeks.ago.to_s }
      let(:end_date) { 1.week.ago.to_s }
      let(:params) { { start_date: start_date, end_date: end_date } }

      it 'returns a RangeFromParams instance' do
        expect(instance.send(:range)).to be_a(AhoyCaptain::RangeFromParams)
      end

      it 'returns a custom range' do
        range = instance.send(:range)
        expect(range.custom?).to be true
      end

      it 'uses the provided dates' do
        range = instance.send(:range)
        expect(range.starts_at).to be_within(1.second).of(start_date.to_datetime)
        expect(range.ends_at).to be_within(1.second).of(end_date.to_datetime)
      end
    end

    context 'with a single date parameter' do
      let(:date) { Date.today.to_s }
      let(:params) { { date: date } }

      it 'returns a RangeFromParams instance' do
        expect(instance.send(:range)).to be_a(AhoyCaptain::RangeFromParams)
      end

      it 'uses the date for the range' do
        range = instance.send(:range)
        expect(range.starts_at.to_date).to eq(Date.today)
        expect(range.ends_at.to_date).to eq(Date.today)
      end
    end

    context 'with realtime period' do
      let(:params) { { period: 'realtime' } }

      it 'returns a RangeFromParams instance' do
        expect(instance.send(:range)).to be_a(AhoyCaptain::RangeFromParams)
      end

      it 'indicates realtime mode' do
        range = instance.send(:range)
        expect(range.realtime?).to be true
      end
    end

    context 'with 30d period' do
      let(:params) { { period: '30d' } }

      it 'returns a range spanning 30 days' do
        range = instance.send(:range)
        expect(range.starts_at).to be_within(1.second).of(30.days.ago)
      end
    end

    context 'with mtd period (month to date)' do
      let(:params) { { period: 'mtd' } }

      it 'returns a range starting from the beginning of the month' do
        range = instance.send(:range)
        expect(range.starts_at.to_date).to eq(Time.current.beginning_of_month.to_date)
      end
    end
  end
end
