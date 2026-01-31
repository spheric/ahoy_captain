# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Tables::Headers::HeaderComponent, type: :component do
  let(:category_name) { 'Page' }
  let(:unit_name) { 'Visitors' }

  subject(:component) do
    described_class.new(category_name: category_name, unit_name: unit_name)
  end

  describe '#initialize' do
    it 'sets category_name' do
      expect(component.instance_variable_get(:@category_name)).to eq(category_name)
    end

    it 'sets unit_name' do
      expect(component.instance_variable_get(:@unit_name)).to eq(unit_name)
    end
  end

  describe '#fixed_height?' do
    it 'returns true' do
      expect(component.fixed_height?).to be true
    end
  end
end
