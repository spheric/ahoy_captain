# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::SourceDecorator do
  let(:object) { double('object', referring_domain: 'google.com', count: 200) }
  let(:params) { ActionController::Parameters.new({}) }
  let(:view_context) do
    double('view_context',
      params: params,
      search_params: {},
      link_to: '<a href="#">google.com</a>'.html_safe
    )
  end
  let(:context) { double('context', view_context: view_context, request: double('request')) }

  subject(:decorator) { described_class.new(object, context) }

  describe '.csv_map' do
    it 'returns a hash with Domain key' do
      result = described_class.csv_map

      expect(result['Domain']).to eq(:referring_domain)
    end

    it 'includes Total key with unit_amount value' do
      result = described_class.csv_map

      expect(result['Total']).to eq(:unit_amount)
    end
  end

  describe '#display_name' do
    before do
      allow(view_context).to receive(:link_to).and_return('<a href="#">google.com</a>'.html_safe)
    end

    it 'returns a link with favicon and domain' do
      result = decorator.display_name

      expect(result).to be_a(String)
      expect(view_context).to have_received(:link_to)
    end

    it 'includes the favicon URL in the display' do
      # The display_name method creates HTML with a favicon image
      # We verify the link_to is called which wraps this HTML
      decorator.display_name

      expect(view_context).to have_received(:link_to) do |display, _path|
        expect(display).to include('google.com')
        expect(display).to include('img')
        expect(display).to include('favicon')
      end
    end
  end

  describe '#unit_amount' do
    it 'returns the object count' do
      expect(decorator.unit_amount).to eq(200)
    end
  end
end
