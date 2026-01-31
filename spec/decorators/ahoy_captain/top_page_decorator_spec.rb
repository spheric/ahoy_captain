# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::TopPageDecorator do
  let(:object) { double('object', url: '/about', count: 75) }
  let(:params) { ActionController::Parameters.new({}) }
  let(:view_context) do
    double('view_context',
      params: params,
      search_params: {},
      link_to: '<a href="#">/about</a>'.html_safe
    )
  end
  let(:context) { double('context', view_context: view_context, request: double('request')) }

  subject(:decorator) { described_class.new(object, context) }

  describe '.csv_map' do
    it 'returns a hash with URL key' do
      result = described_class.csv_map

      expect(result['URL']).to eq(:label)
    end

    it 'includes Total key with unit_amount value' do
      result = described_class.csv_map

      expect(result['Total']).to eq(:unit_amount)
    end
  end

  describe '#type' do
    it 'returns :route_eq' do
      expect(decorator.type).to eq(:route_eq)
    end
  end

  describe '#label' do
    it 'returns the object url' do
      expect(decorator.label).to eq('/about')
    end
  end

  describe '#display_name' do
    before do
      allow(view_context).to receive(:link_to).and_return('<a href="#">/about</a>'.html_safe)
    end

    it 'returns a link with the URL' do
      result = decorator.display_name

      expect(result).to be_a(String)
      expect(view_context).to have_received(:link_to)
    end
  end

  describe '#unit_amount' do
    it 'returns the object count' do
      expect(decorator.unit_amount).to eq(75)
    end
  end
end
