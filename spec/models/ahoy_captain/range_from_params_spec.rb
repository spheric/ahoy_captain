# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::RangeFromParams do
  describe '.from_params' do
    it 'returns an instance of RangeFromParams' do
      params = { period: '30d' }
      result = described_class.from_params(params)

      expect(result).to be_a(described_class)
    end

    it 'builds the range automatically' do
      params = { period: '30d' }
      result = described_class.from_params(params)

      expect(result.range).not_to be_nil
    end

    it 'passes comparison mode to the instance' do
      params = { period: '30d', comparison: 'previous' }
      result = described_class.from_params(params)

      expect(result).to be_a(described_class)
    end
  end

  describe '#initialize' do
    it 'uses default period when not provided' do
      instance = described_class.new
      instance.build

      expect(instance.range).not_to be_nil
    end

    it 'accepts period parameter' do
      instance = described_class.new(period: '7d')
      instance.build

      expect(instance.range).not_to be_nil
    end

    it 'accepts start_date and end_date parameters' do
      instance = described_class.new(start_date: '2024-01-01', end_date: '2024-01-31')
      instance.build

      expect(instance.range).not_to be_nil
    end

    it 'accepts date parameter' do
      instance = described_class.new(date: '2024-01-15')
      instance.build

      expect(instance.range).not_to be_nil
    end
  end

  describe '#build' do
    context 'with custom date range' do
      it 'creates range from start_date and end_date' do
        start_date = '2024-01-01'
        end_date = '2024-01-31'
        instance = described_class.new(start_date: start_date, end_date: end_date)

        result = instance.build

        expect(result).to eq(instance)
        expect(instance.range.min.to_date).to eq(Date.parse(start_date))
        expect(instance.range.max.to_date).to eq(Date.parse(end_date))
      end

      it 'sorts dates correctly when start_date is after end_date' do
        start_date = '2024-01-31'
        end_date = '2024-01-01'
        instance = described_class.new(start_date: start_date, end_date: end_date)

        instance.build

        expect(instance.range.min.to_date).to eq(Date.parse(end_date))
        expect(instance.range.max.to_date).to eq(Date.parse(start_date))
      end
    end

    context 'with single date' do
      it 'creates range for the entire day' do
        date = '2024-01-15'
        instance = described_class.new(date: date)

        instance.build

        expect(instance.range.min.to_date).to eq(Date.parse(date))
        expect(instance.range.max.to_date).to eq(Date.parse(date))
      end
    end

    context 'with period' do
      it 'uses the configured period range' do
        instance = described_class.new(period: '30d')

        instance.build

        expect(instance.range).not_to be_nil
        expect(instance.range.min).to be < instance.range.max
      end

      it 'falls back to default period when period is nil' do
        instance = described_class.new(period: nil)

        instance.build

        expect(instance.range).not_to be_nil
      end
    end

    it 'returns self' do
      instance = described_class.new(period: '30d')

      result = instance.build

      expect(result).to eq(instance)
    end
  end

  describe '#starts_at' do
    it 'returns the start time of the range' do
      instance = described_class.new(start_date: '2024-01-01', end_date: '2024-01-31')
      instance.build

      expect(instance.starts_at).to be_a(Time)
      expect(instance.starts_at.to_date).to eq(Date.parse('2024-01-01'))
    end
  end

  describe '#ends_at' do
    context 'when not realtime' do
      it 'returns the end time of the range' do
        instance = described_class.new(start_date: '2024-01-01', end_date: '2024-01-31')
        instance.build

        expect(instance.ends_at).to be_a(Time)
        expect(instance.ends_at.to_date).to eq(Date.parse('2024-01-31'))
      end
    end

    context 'when realtime' do
      it 'returns the current time' do
        instance = described_class.new(period: 'realtime')
        instance.build

        expect(instance.ends_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe '#realtime?' do
    it 'returns true when the range end is nil' do
      instance = described_class.new(period: 'realtime')
      instance.build

      expect(instance.realtime?).to be true
    end

    it 'returns false when the range end is present' do
      instance = described_class.new(period: '30d')
      instance.build

      expect(instance.realtime?).to be false
    end
  end

  describe '#custom?' do
    it 'returns true when start_date and end_date are provided' do
      instance = described_class.new(
        start_date: '2024-01-01',
        end_date: '2024-01-31',
        raw: { start_date: '2024-01-01', end_date: '2024-01-31' }
      )
      instance.build

      expect(instance.custom?).to be true
    end

    it 'returns false when only period is provided' do
      instance = described_class.new(period: '30d', raw: { period: '30d' })
      instance.build

      expect(instance.custom?).to be false
    end

    it 'returns false when raw params are empty' do
      instance = described_class.new(start_date: '2024-01-01', end_date: '2024-01-31', raw: {})
      instance.build

      expect(instance.custom?).to be false
    end
  end

  describe '#[]' do
    let(:instance) do
      described_class.new(start_date: '2024-01-01', end_date: '2024-01-31').tap(&:build)
    end

    it 'returns starts_at for index 0' do
      expect(instance[0]).to eq(instance.starts_at)
    end

    it 'returns ends_at for index 1' do
      expect(instance[1]).to eq(instance.ends_at)
    end

    it 'raises NoMethodError for other indices' do
      expect { instance[2] }.to raise_error(NoMethodError)
      expect { instance[-1] }.to raise_error(NoMethodError)
    end
  end

  describe '#numeric' do
    it 'returns an integer-based range' do
      instance = described_class.new(start_date: '2024-01-01', end_date: '2024-01-31')
      instance.build

      numeric_range = instance.numeric

      expect(numeric_range).to be_a(Range)
      expect(numeric_range.min).to be_a(Integer)
      expect(numeric_range.max).to be_a(Integer)
    end

    it 'is memoized' do
      instance = described_class.new(period: '30d')
      instance.build

      first_call = instance.numeric
      second_call = instance.numeric

      expect(first_call).to equal(second_call)
    end
  end

  describe '#selected_period' do
    it 'returns the configured period range' do
      instance = described_class.new(period: '30d')

      result = instance.selected_period

      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
    end

    it 'falls back to default period when period is invalid' do
      instance = described_class.new(period: 'invalid_period')

      result = instance.selected_period

      expect(result).not_to be_nil
    end
  end

  describe '#params' do
    it 'returns the params reader' do
      instance = described_class.new(period: '30d')

      expect(instance).to respond_to(:params)
    end
  end

  describe '#range' do
    it 'returns the range reader' do
      instance = described_class.new(period: '30d')
      instance.build

      expect(instance).to respond_to(:range)
      expect(instance.range).to be_a(Range)
    end
  end
end
