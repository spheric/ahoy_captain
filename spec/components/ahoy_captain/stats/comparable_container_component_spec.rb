# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::ComparableContainerComponent, type: :component do
  let(:url) { '/stats' }
  let(:label) { 'Visitors' }
  let(:formatter) { :number_with_delimiter }
  let(:selected) { false }
  let(:compare) { true }

  let(:current_value) { 100 }
  let(:compared_value) { 80 }
  let(:comparison_result) do
    AhoyCaptain::ComparableQuery::Comparison::ComparisonResult.new(current_value, compared_value)
  end

  let(:range_start) { Time.zone.now.beginning_of_day - 7.days }
  let(:range_end) { Time.zone.now.end_of_day }
  let(:compare_range_start) { range_start - 7.days }
  let(:compare_range_end) { range_start }

  let(:comparable) do
    double(
      'Comparable',
      result: comparison_result,
      range: [range_start, range_end],
      compare_range: [compare_range_start, compare_range_end]
    )
  end

  subject(:component) do
    described_class.new(url, label, comparable, formatter, selected, compare)
  end

  describe '#initialize' do
    it 'sets instance variables' do
      expect(component.instance_variable_get(:@url)).to eq(url)
      expect(component.instance_variable_get(:@label)).to eq(label)
      expect(component.instance_variable_get(:@comparable)).to eq(comparable)
      expect(component.instance_variable_get(:@formatter)).to eq(formatter)
      expect(component.instance_variable_get(:@selected)).to eq(selected)
      expect(component.instance_variable_get(:@compare)).to eq(compare)
    end
  end

  describe '#compare?' do
    context 'when compare is true' do
      let(:compare) { true }

      it 'returns true' do
        expect(component.compare?).to be true
      end
    end

    context 'when compare is false' do
      let(:compare) { false }

      it 'returns false' do
        expect(component.compare?).to be false
      end
    end
  end

  describe '#klass' do
    context 'when percentage is negative' do
      let(:current_value) { 50 }
      let(:compared_value) { 100 }

      it 'returns red class' do
        expect(component.klass).to eq('text-red-400')
      end
    end

    context 'when percentage is positive' do
      let(:current_value) { 100 }
      let(:compared_value) { 50 }

      it 'returns green class' do
        expect(component.klass).to eq('text-green-400')
      end
    end
  end

  describe '#arrow' do
    context 'when percentage is negative' do
      let(:current_value) { 50 }
      let(:compared_value) { 100 }

      it 'returns down arrow' do
        expect(component.arrow).to eq('↓')
      end
    end

    context 'when percentage is positive' do
      let(:current_value) { 100 }
      let(:compared_value) { 50 }

      it 'returns up arrow' do
        expect(component.arrow).to eq('↑')
      end
    end

    context 'when percentage is zero' do
      let(:current_value) { 100 }
      let(:compared_value) { 100 }

      it 'returns wave' do
        expect(component.arrow).to eq('〰')
      end
    end
  end

  describe '#percentage' do
    context 'when both values are present and different' do
      let(:current_value) { 100 }
      let(:compared_value) { 80 }

      it 'calculates percentage correctly' do
        # diff = 100 - 80 = 20
        # percentage = (100 / 20).round(2) * 100 = 5.0 * 100 = 500.0
        expect(component.percentage).to eq(500.0)
      end
    end

    context 'when current value is nil' do
      let(:current_value) { nil }
      let(:compared_value) { 80 }

      it 'returns 0' do
        expect(component.percentage).to eq(0)
      end
    end

    context 'when compared_to value is nil' do
      let(:current_value) { 100 }
      let(:compared_value) { nil }

      it 'returns 0' do
        expect(component.percentage).to eq(0)
      end
    end

    context 'when values are equal' do
      let(:current_value) { 100 }
      let(:compared_value) { 100 }

      it 'returns 0' do
        expect(component.percentage).to eq(0)
      end
    end

    context 'when division by zero would occur' do
      let(:current_value) { 0 }
      let(:compared_value) { 0 }

      it 'returns 0' do
        expect(component.percentage).to eq(0)
      end
    end
  end

  describe '#number_to_duration' do
    context 'when duration is present' do
      it 'formats duration correctly' do
        duration = 2.minutes + 5.seconds
        expect(component.number_to_duration(duration)).to eq('2M 5S')
      end
    end

    context 'when duration is nil' do
      it 'returns default value' do
        expect(component.number_to_duration(nil)).to eq('0M 0S')
      end
    end
  end

  describe '#compare_range_string' do
    it 'formats the compare range as a string' do
      result = component.compare_range_string
      expect(result).to include(compare_range_start.strftime('%m %B'))
      expect(result).to include(compare_range_end.strftime('%m %B'))
      expect(result).to include(' - ')
    end
  end

  describe '#range_string' do
    it 'formats the range as a string' do
      result = component.range_string
      expect(result).to include(range_start.strftime('%m %B'))
      expect(result).to include(range_end.strftime('%m %B'))
      expect(result).to include(' - ')
    end
  end

  describe '#value' do
    it 'returns the comparison result' do
      expect(component.value).to eq(comparison_result)
    end
  end

  describe '#formatted' do
    it 'calls the formatter method with the value' do
      expect(component).to receive(:number_with_delimiter).with(100)
      component.formatted(100)
    end
  end

  describe '#tooltip' do
    before do
      allow(component).to receive(:number_with_delimiter) { |v| v.to_s }
      allow(component).to receive(:number_to_percentage) { |v| "#{v}%" }
    end

    it 'returns a formatted tooltip string' do
      result = component.tooltip
      expect(result).to include('100')
      expect(result).to include('80')
      expect(result).to include('vs')
    end
  end
end
