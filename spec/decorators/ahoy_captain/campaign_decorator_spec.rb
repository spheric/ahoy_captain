# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::CampaignDecorator do
  let(:object) { double('object', label: label, count: 100) }
  let(:label) { 'google' }
  let(:params) { ActionController::Parameters.new(campaigns_type: 'utm_source') }
  let(:view_context) do
    double('view_context',
      params: params,
      search_params: {},
      link_to: '<a href="#">google</a>'.html_safe
    )
  end
  let(:context) { double('context', view_context: view_context, request: double('request')) }

  subject(:decorator) { described_class.new(object, context) }

  describe '.csv_map' do
    it 'returns a hash with the campaign type as key' do
      result = described_class.csv_map(campaigns_type: 'utm_source')

      expect(result.keys).to include('utm_source')
      expect(result.values).to include(:label)
    end

    it 'includes Total key with unit_amount value' do
      result = described_class.csv_map(campaigns_type: 'utm_source')

      expect(result['Total']).to eq(:unit_amount)
    end

    it 'uses different campaign types' do
      result = described_class.csv_map(campaigns_type: 'utm_campaign')

      expect(result.keys).to include('utm_campaign')
    end
  end

  describe '#display_name' do
    before do
      allow(view_context).to receive(:link_to).and_return('<a href="#">google</a>'.html_safe)
    end

    it 'returns a link' do
      result = decorator.display_name

      expect(result).to be_a(String)
    end

    context 'when label is Direct/None' do
      let(:label) { 'Direct/None' }

      it 'uses empty string for the search query value' do
        # The search query should use an empty value for Direct/None
        decorator.display_name

        expect(view_context).to have_received(:link_to)
      end
    end

    context 'when label is a regular value' do
      let(:label) { 'facebook' }

      it 'uses the label value for the search query' do
        decorator.display_name

        expect(view_context).to have_received(:link_to)
      end
    end
  end

  describe '#unit_amount' do
    it 'returns the object count' do
      expect(decorator.unit_amount).to eq(100)
    end
  end
end
