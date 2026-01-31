# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::DropdownLinkComponent, type: :component do
  let(:title) { 'Test Link Dropdown' }
  let(:classes) { nil }

  subject(:component) do
    described_class.new(title: title, classes: classes)
  end

  describe '#initialize' do
    it 'sets the title' do
      expect(component.send(:title)).to eq(title)
    end

    it 'sets classes to nil by default' do
      expect(component.send(:classes)).to be_nil
    end

    context 'with custom classes' do
      let(:classes) { 'custom-class btn-primary' }

      it 'sets the classes' do
        expect(component.send(:classes)).to eq(classes)
      end
    end
  end

  describe 'slots' do
    it 'renders_many options' do
      expect(described_class).to respond_to(:renders_many)
    end

    it 'renders_one header' do
      expect(described_class).to respond_to(:renders_one)
    end
  end

  describe '#link_to' do
    it 'is defined as a public method' do
      expect(component).to respond_to(:link_to)
    end
  end
end
