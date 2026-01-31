# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::TileComponent, type: :component do
  let(:title) { 'Test Tile' }
  let(:wide) { false }
  let(:classes) { 'p-8 mx-4' }

  subject(:component) do
    described_class.new(title: title, wide: wide, classes: classes)
  end

  describe '#initialize' do
    it 'sets the title' do
      expect(component.send(:title)).to eq(title)
    end

    it 'sets wide' do
      expect(component.send(:wide)).to eq(wide)
    end

    it 'sets classes' do
      expect(component.instance_variable_get(:@classes)).to eq(classes)
    end

    context 'with default values' do
      subject(:component) { described_class.new }

      it 'has nil title' do
        expect(component.send(:title)).to be_nil
      end

      it 'has false wide' do
        expect(component.send(:wide)).to be false
      end

      it 'has default classes' do
        expect(component.instance_variable_get(:@classes)).to eq('p-8 mx-4')
      end
    end

    context 'when wide is true' do
      let(:wide) { true }

      it 'sets wide to true' do
        expect(component.send(:wide)).to be true
      end
    end

    context 'with custom classes' do
      let(:classes) { 'custom-class p-4' }

      it 'sets custom classes' do
        expect(component.instance_variable_get(:@classes)).to eq(classes)
      end
    end
  end

  describe 'slots' do
    it 'renders_one statistic_display' do
      expect(described_class).to respond_to(:renders_one)
    end

    it 'renders_one display_links' do
      expect(described_class).to respond_to(:renders_one)
    end

    it 'renders_one details_cta' do
      expect(described_class).to respond_to(:renders_one)
    end
  end

  describe '#link_to' do
    let(:view_context) { double('ViewContext') }

    before do
      allow(component).to receive(:view_context).and_return(view_context)
      allow(view_context).to receive(:link_to).and_return('<a href="/test">Test</a>'.html_safe)
    end

    it 'creates a link with proper defaults' do
      expect(view_context).to receive(:link_to).with(
        'Test Link',
        '/test',
        class: 'inline-block h-5 font-semibold',
        data: { controller: 'frame-link' }
      )
      component.link_to('Test Link', '/test')
    end

    it 'merges custom data attributes' do
      expect(view_context).to receive(:link_to).with(
        'Test Link',
        '/test',
        class: 'inline-block h-5 font-semibold',
        data: { controller: 'frame-link', action: 'click' }
      )
      component.link_to('Test Link', '/test', data: { action: 'click' })
    end
  end
end
