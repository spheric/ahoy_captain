# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::DeviceDecorator do
  let(:object) { double('object', label: 'Chrome', count: 150, total_count: 500) }
  let(:params) { ActionController::Parameters.new(devices_type: 'browser') }
  let(:view_context) do
    double('view_context',
      params: params,
      search_params: {},
      link_to: '<a href="#">Chrome</a>'.html_safe
    )
  end
  let(:context) { double('context', view_context: view_context, request: double('request')) }

  subject(:decorator) { described_class.new(object, context) }

  describe '.csv_map' do
    it 'returns a hash with the device type as key' do
      result = described_class.csv_map(devices_type: 'browser')

      expect(result.keys).to include('browser')
      expect(result.values).to include(:label)
    end

    it 'includes Total key with unit_amount value' do
      result = described_class.csv_map(devices_type: 'browser')

      expect(result['Total']).to eq(:unit_amount)
    end

    it 'works with os device type' do
      result = described_class.csv_map(devices_type: 'os')

      expect(result.keys).to include('os')
    end

    it 'works with device_type' do
      result = described_class.csv_map(devices_type: 'device_type')

      expect(result.keys).to include('device_type')
    end
  end

  describe '#display_name' do
    before do
      allow(view_context).to receive(:link_to).and_return('<a href="#">Chrome</a>'.html_safe)
    end

    it 'returns a link with the label' do
      result = decorator.display_name

      expect(result).to be_a(String)
      expect(view_context).to have_received(:link_to)
    end
  end

  describe '#label' do
    it 'returns the object label' do
      expect(decorator.label).to eq('Chrome')
    end
  end

  describe '#unit_amount' do
    it 'returns the object count' do
      expect(decorator.unit_amount).to eq(150)
    end
  end

  describe '#total_count' do
    it 'returns the object total_count' do
      expect(decorator.total_count).to eq(500)
    end
  end
end
