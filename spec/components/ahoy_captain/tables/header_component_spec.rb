# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Tables::HeaderComponent, type: :component do
  let(:headers) { [{ label: 'Name', grow: true }, { label: 'Count', grow: false }] }
  let(:options) { {} }

  subject(:component) do
    described_class.new(headers, options)
  end

  describe '#initialize' do
    it 'flattens and stores headers' do
      expect(component.instance_variable_get(:@headers)).to eq(headers.flatten)
    end

    it 'stores options' do
      expect(component.instance_variable_get(:@options)).to eq(options)
    end

    context 'with nested headers array' do
      let(:headers) { [[{ label: 'Name' }], [{ label: 'Count' }]] }

      it 'flattens nested arrays' do
        expect(component.instance_variable_get(:@headers)).to eq([{ label: 'Name' }, { label: 'Count' }])
      end
    end
  end

  describe '#fixed_height?' do
    context 'when fixed_height is not specified' do
      let(:options) { {} }

      it 'returns true by default' do
        expect(component.fixed_height?).to be true
      end
    end

    context 'when fixed_height is explicitly true' do
      let(:options) { { fixed_height: true } }

      it 'returns true' do
        expect(component.fixed_height?).to be true
      end
    end

    context 'when fixed_height is explicitly false' do
      let(:options) { { fixed_height: false } }

      it 'returns false' do
        expect(component.fixed_height?).to be false
      end
    end
  end
end
