# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::ComboboxComponent, type: :component do
  let(:name) { 'test_combobox' }
  let(:column) { :country }
  let(:url) { '/search' }
  let(:multiple) { false }
  let(:disabled) { false }
  let(:value) { [] }
  let(:select_html) { {} }

  subject(:component) do
    described_class.new(
      name: name,
      column: column,
      url: url,
      multiple: multiple,
      disabled: disabled,
      value: value,
      select_html: select_html
    )
  end

  describe '#initialize' do
    it 'sets the name' do
      expect(component.instance_variable_get(:@name)).to eq(name)
    end

    it 'sets the column' do
      expect(component.instance_variable_get(:@column)).to eq(column)
    end

    it 'sets the url' do
      expect(component.instance_variable_get(:@url)).to eq(url)
    end

    it 'sets multiple' do
      expect(component.instance_variable_get(:@multiple)).to eq(multiple)
    end

    it 'sets disabled' do
      expect(component.instance_variable_get(:@disabled)).to eq(disabled)
    end

    it 'sets select_html' do
      expect(component.instance_variable_get(:@select_html)).to eq(select_html)
    end

    context 'when value is a single item' do
      let(:value) { 'US' }

      it 'wraps value in an array' do
        expect(component.instance_variable_get(:@value)).to eq(['US'])
      end
    end

    context 'when value is an array' do
      let(:value) { ['US', 'CA'] }

      it 'keeps value as array' do
        expect(component.instance_variable_get(:@value)).to eq(['US', 'CA'])
      end
    end

    context 'when value is empty' do
      let(:value) { [] }

      it 'keeps value as empty array' do
        expect(component.instance_variable_get(:@value)).to eq([])
      end
    end

    context 'when multiple is true' do
      let(:multiple) { true }

      it 'sets multiple to true' do
        expect(component.instance_variable_get(:@multiple)).to be true
      end
    end

    context 'when disabled is true' do
      let(:disabled) { true }

      it 'sets disabled to true' do
        expect(component.instance_variable_get(:@disabled)).to be true
      end
    end

    context 'when select_html has options' do
      let(:select_html) { { class: 'custom-class', id: 'custom-id' } }

      it 'sets select_html with options' do
        expect(component.instance_variable_get(:@select_html)).to eq(select_html)
      end
    end
  end
end
