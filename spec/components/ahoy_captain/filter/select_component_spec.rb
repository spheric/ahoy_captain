# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Filter::SelectComponent, type: :component do
  let(:label) { 'Country' }
  let(:column) { :country }
  let(:url) { '/countries' }
  let(:predicates) { [:eq, :not_eq, :cont] }
  let(:form) { double('Form') }
  let(:multiple) { true }
  let(:input_html) { {} }

  subject(:component) do
    described_class.new(
      label: label,
      column: column,
      url: url,
      predicates: predicates,
      form: form,
      multiple: multiple,
      input_html: input_html
    )
  end

  describe '#initialize' do
    it 'sets label' do
      expect(component.send(:label)).to eq(label)
    end

    it 'sets column' do
      expect(component.send(:column)).to eq(column)
    end

    it 'sets url' do
      expect(component.send(:url)).to eq(url)
    end

    it 'sets predicates' do
      expect(component.send(:predicates)).to eq(predicates)
    end

    it 'sets form' do
      expect(component.send(:form)).to eq(form)
    end

    it 'sets multiple' do
      expect(component.send(:multiple)).to eq(multiple)
    end

    context 'with custom input_html' do
      let(:input_html) { { class: 'custom-input' } }

      it 'sets input_html_options' do
        expect(component.instance_variable_get(:@input_html_options)).to eq(input_html)
      end
    end
  end

  describe '#predicate_name' do
    it 'combines column and predicate' do
      expect(component.send(:predicate_name, :eq)).to eq('country_eq')
    end

    it 'handles different predicates' do
      expect(component.send(:predicate_name, :cont)).to eq('country_cont')
      expect(component.send(:predicate_name, :not_eq)).to eq('country_not_eq')
    end
  end

  describe '#option_value' do
    context 'when multiple is true' do
      let(:multiple) { true }

      it 'returns name with array brackets' do
        expect(component.send(:option_value, :eq)).to eq('q[country_eq][]')
      end
    end

    context 'when multiple is false' do
      let(:multiple) { false }

      it 'returns name without array brackets' do
        expect(component.send(:option_value, :eq)).to eq('q[country_eq]')
      end
    end
  end

  # Note: Methods that use params require view_context/controller
  # which is only available after rendering. Testing these methods
  # would require integration tests with full rendering context.

  describe '#selected_predicate?' do
    it 'is defined as a private method' do
      expect(component.respond_to?(:selected_predicate?, true)).to be true
    end
  end

  describe '#selected_predicate' do
    it 'is defined as a private method' do
      expect(component.respond_to?(:selected_predicate, true)).to be true
    end
  end

  describe '#column_name_with_predicate' do
    it 'is defined as a private method' do
      expect(component.respond_to?(:column_name_with_predicate, true)).to be true
    end
  end

  describe '#values' do
    it 'is defined as a private method' do
      expect(component.respond_to?(:values, true)).to be true
    end
  end

  describe '#predicate_label' do
    it 'returns label from PredicateLabel' do
      expect(AhoyCaptain::PredicateLabel).to receive(:[]).with(:eq).and_return('is')
      component.send(:predicate_label, :eq)
    end
  end
end
