# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Filter::DropdownComponent, type: :component do
  let(:filters) { {} }

  subject(:component) do
    described_class.new(filters: filters)
  end

  describe '#initialize' do
    it 'sets filters' do
      expect(component.send(:filters)).to eq(filters)
    end
  end

  describe '#header_icon' do
    context 'when advanced_filter_menu? is true' do
      before do
        allow(component).to receive(:advanced_filter_menu?).and_return(true)
      end

      it 'returns filters icon' do
        expect(component.send(:header_icon)).to include('svg')
        expect(component.send(:header_icon)).to include('viewBox="0 0 20 20"')
      end
    end

    context 'when advanced_filter_menu? is false' do
      before do
        allow(component).to receive(:advanced_filter_menu?).and_return(false)
      end

      it 'returns magnifier icon' do
        result = component.send(:header_icon)
        expect(result).to include('svg')
        expect(result).to include('fill-rule="evenodd"')
      end
    end
  end

  describe '#title' do
    context 'when advanced_filter_menu? is true' do
      # title uses filters.size which counts the top-level keys in the hash
      # So for { filter1: x, filter2: y, filter3: z } => filters.size = 3
      let(:filters) do
        {
          filter1: { a: double },
          filter2: { b: double },
          filter3: { c: double }
        }
      end

      before do
        allow(component).to receive(:advanced_filter_menu?).and_return(true)
      end

      it 'returns filter count' do
        expect(component.send(:title)).to eq('3 Filters')
      end
    end

    context 'when advanced_filter_menu? is false' do
      before do
        allow(component).to receive(:advanced_filter_menu?).and_return(false)
      end

      it 'returns Filter' do
        expect(component.send(:title)).to eq('Filter')
      end
    end
  end

  describe '#advanced_filter_menu?' do
    context 'when filter_categories count is >= FILTER_MENU_MAX_SIZE' do
      let(:filters) do
        {
          filter1: { a: double, b: double }
        }
      end

      it 'returns true' do
        expect(component.send(:advanced_filter_menu?)).to be true
      end
    end

    context 'when filter_categories count is < FILTER_MENU_MAX_SIZE' do
      let(:filters) do
        { filter1: { a: double } }
      end

      it 'returns false' do
        expect(component.send(:advanced_filter_menu?)).to be false
      end
    end

    context 'when filters is empty' do
      let(:filters) { {} }

      it 'returns false' do
        expect(component.send(:advanced_filter_menu?)).to be false
      end
    end
  end

  describe '#filter_categories' do
    context 'with nested filter values' do
      let(:filter_a) { double('FilterA') }
      let(:filter_b) { double('FilterB') }
      let(:filter_c) { double('FilterC') }
      let(:filters) do
        {
          group1: { a: filter_a, b: filter_b },
          group2: { c: filter_c }
        }
      end

      it 'flattens all filter values' do
        result = component.send(:filter_categories)
        expect(result).to contain_exactly(filter_a, filter_b, filter_c)
      end
    end

    context 'with empty filters' do
      let(:filters) { {} }

      it 'returns empty array' do
        expect(component.send(:filter_categories)).to eq([])
      end
    end
  end

  describe '#magnifier_icon' do
    it 'returns an SVG string' do
      result = component.send(:magnifier_icon)
      expect(result).to be_html_safe
      expect(result).to include('<svg')
      expect(result).to include('</svg>')
    end

    it 'includes proper styling classes' do
      result = component.send(:magnifier_icon)
      expect(result).to include('-ml-1')
      expect(result).to include('mr-1')
      expect(result).to include('h-4')
      expect(result).to include('w-4')
    end
  end

  describe '#filters_icon' do
    it 'returns an SVG string' do
      result = component.send(:filters_icon)
      expect(result).to be_html_safe
      expect(result).to include('<svg')
      expect(result).to include('</svg>')
    end

    it 'includes proper styling classes' do
      result = component.send(:filters_icon)
      expect(result).to include('-ml-1')
      expect(result).to include('mr-1')
      expect(result).to include('h-4')
      expect(result).to include('w-4')
    end
  end

  describe '#edit_icon' do
    it 'returns an SVG string' do
      result = component.send(:edit_icon)
      expect(result).to be_html_safe
      expect(result).to include('<svg')
      expect(result).to include('</svg>')
    end

    it 'includes cursor-pointer class' do
      result = component.send(:edit_icon)
      expect(result).to include('cursor-pointer')
    end
  end

  describe '#remove_icon' do
    it 'returns an SVG string' do
      result = component.send(:remove_icon)
      expect(result).to be_html_safe
      expect(result).to include('<svg')
      expect(result).to include('</svg>')
    end

    it 'includes proper dimensions' do
      result = component.send(:remove_icon)
      expect(result).to include('w-4')
      expect(result).to include('h-4')
    end
  end
end
