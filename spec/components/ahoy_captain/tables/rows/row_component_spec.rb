# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Tables::Rows::RowComponent, type: :component do
  let(:table) { double('Table') }
  let(:item) { double('Item', unit_amount: 50) }

  subject(:component) do
    described_class.new(table: table, item: item)
  end

  describe '#initialize' do
    it 'sets table' do
      expect(component.instance_variable_get(:@table)).to eq(table)
    end

    it 'sets item' do
      expect(component.instance_variable_get(:@item)).to eq(item)
    end
  end

  describe '#progress_bar' do
    let(:view_context) { double('ViewContext') }

    before do
      allow(component).to receive(:view_context).and_return(view_context)
      allow(view_context).to receive(:content_tag).and_return(''.html_safe)
    end

    it 'creates progress and span elements' do
      expect(view_context).to receive(:content_tag).with(:progress, '', hash_including(class: 'progress-primary bg-base-100 h-8 grow'))
      expect(view_context).to receive(:content_tag).with(:span, hash_including(class: /grow text-elipsis/))
      component.progress_bar(50, 100, 'Label')
    end
  end

  describe '#item' do
    let(:view_context) { double('ViewContext') }

    before do
      allow(component).to receive(:view_context).and_return(view_context)
      allow(view_context).to receive(:content_tag).and_yield
    end

    it 'creates a span element with value' do
      expect(view_context).to receive(:content_tag).with(:span, hash_including(class: /w-8 ml-8 text-right/))
      component.item('test value')
    end
  end

  describe '#percent_total' do
    it 'is defined as a public method' do
      expect(component).to respond_to(:percent_total)
    end
  end

  describe '#tooltip' do
    it 'creates a TooltipComponent' do
      tooltip_component = double('TooltipComponent')
      expect(AhoyCaptain::TooltipComponent).to receive(:new).with(amount: 100).and_return(tooltip_component)
      expect(tooltip_component).to receive(:render_in).with(component)
      component.tooltip(100)
    end
  end
end
