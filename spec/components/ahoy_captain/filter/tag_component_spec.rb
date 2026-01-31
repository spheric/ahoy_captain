# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Filter::TagComponent, type: :component do
  let(:modal) { 'country_modal' }
  let(:tag_item) { double('TagItem', modal: modal) }

  subject(:component) do
    described_class.new(tag_item: tag_item)
  end

  describe '#initialize' do
    it 'sets the tag_item' do
      expect(component.send(:tag_item)).to eq(tag_item)
    end
  end

  describe '#modal' do
    it 'returns the modal from tag_item' do
      expect(component.send(:modal)).to eq(modal)
    end
  end
end
