# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Filter::ModalComponent, type: :component do
  let(:title) { 'Filter Modal' }
  let(:id) { 'filter-modal' }

  subject(:component) do
    described_class.new(title: title, id: id)
  end

  describe '#initialize' do
    it 'sets the title' do
      expect(component.send(:title)).to eq(title)
    end

    it 'sets the id' do
      expect(component.send(:id)).to eq(id)
    end

    context 'when title is nil' do
      let(:title) { nil }

      it 'allows nil title' do
        expect(component.send(:title)).to be_nil
      end
    end
  end

  describe 'slots' do
    it 'renders_one modal_display' do
      expect(described_class).to respond_to(:renders_one)
    end
  end
end
