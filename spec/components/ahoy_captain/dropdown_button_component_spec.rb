# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::DropdownButtonComponent, type: :component do
  let(:title) { 'Test Dropdown' }

  subject(:component) do
    described_class.new(title: title)
  end

  describe '#initialize' do
    it 'sets the title' do
      expect(component.send(:title)).to eq(title)
    end
  end

  describe 'slots' do
    it 'renders_many options' do
      expect(described_class).to respond_to(:renders_many)
    end

    it 'renders_one header_icon' do
      expect(described_class).to respond_to(:renders_one)
    end
  end
end
