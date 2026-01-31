# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Tables::PropertiesTableComponent, type: :component do
  describe '.table' do
    it 'returns a registered table' do
      expect(described_class.table).to be_a(AhoyCaptain::Tables::DynamicTableComponent)
    end

    it 'has appropriate headers' do
      headers = described_class.table.headers
      header_list = headers.instance_variable_get(:@headers)
      labels = header_list.map { |h| h[:label] }
      expect(labels).to include('Name', 'Visitors', 'Events', '%')
    end
  end

  describe '.url' do
    let(:request) { double('Request', params: { id: Base64.encode64('test_property') }) }
    let(:item) { double('Item', label: 'test_value') }
    let(:item_wrapper) do
      double('ItemWrapper',
        request: request,
        search_params: { 'page' => '1' },
        item: item
      )
    end

    it 'builds URL with properties_json_cont' do
      result = described_class.url(item_wrapper)
      expect(result[:q]).to have_key('properties_json_cont')
    end

    context 'when existing properties_json_cont is present' do
      let(:existing_json) { { 'existing_key' => 'existing_value' }.to_json }
      let(:item_wrapper) do
        double('ItemWrapper',
          request: request,
          search_params: { 'q' => { 'properties_json_cont' => existing_json } },
          item: item
        )
      end

      it 'merges with existing properties' do
        result = described_class.url(item_wrapper)
        json = JSON.parse(result['q']['properties_json_cont'])
        expect(json).to have_key('existing_key')
        expect(json).to have_key('test_property')
      end
    end
  end
end
