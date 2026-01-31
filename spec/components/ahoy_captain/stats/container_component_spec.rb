# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::ContainerComponent, type: :component do
  let(:url) { '/stats' }
  let(:label) { 'Visitors' }
  let(:value) { 100 }
  let(:formatter) { :number_with_delimiter }
  let(:selected) { false }

  subject(:component) do
    described_class.new(url, label, value, formatter, selected)
  end

  describe '#initialize' do
    it 'sets url' do
      expect(component.instance_variable_get(:@url)).to eq(url)
    end

    it 'sets label' do
      expect(component.instance_variable_get(:@label)).to eq(label)
    end

    it 'sets value' do
      expect(component.instance_variable_get(:@value)).to eq(value)
    end

    it 'sets formatter' do
      expect(component.instance_variable_get(:@formatter)).to eq(formatter)
    end

    it 'sets selected' do
      expect(component.instance_variable_get(:@selected)).to eq(selected)
    end

    context 'when selected is true' do
      let(:selected) { true }

      it 'sets selected to true' do
        expect(component.instance_variable_get(:@selected)).to be true
      end
    end
  end

  describe '#formatted' do
    it 'calls the formatter method with value' do
      expect(component).to receive(:number_with_delimiter).with(100)
      component.formatted(100)
    end

    context 'with different formatter' do
      let(:formatter) { :number_to_duration }

      it 'calls the appropriate formatter' do
        duration = 2.minutes + 30.seconds
        expect(component).to receive(:number_to_duration).with(duration)
        component.formatted(duration)
      end
    end
  end

  describe '#number_to_duration' do
    context 'when duration is present' do
      it 'formats duration correctly' do
        duration = 2.minutes + 30.seconds
        expect(component.number_to_duration(duration)).to eq('2M 30S')
      end
    end

    context 'when duration has only minutes' do
      it 'formats with zero seconds' do
        duration = 5.minutes
        expect(component.number_to_duration(duration)).to eq('5M 0S')
      end
    end

    context 'when duration has only seconds' do
      it 'formats with zero minutes' do
        duration = 45.seconds
        expect(component.number_to_duration(duration)).to eq('0M 45S')
      end
    end

    context 'when duration is nil' do
      it 'returns default value' do
        expect(component.number_to_duration(nil)).to eq('0M 0S')
      end
    end
  end
end
