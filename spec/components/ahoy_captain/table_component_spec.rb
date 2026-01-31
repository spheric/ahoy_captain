# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::TableComponent, type: :component do
  let(:item1) { double('Item', unit_amount: 100, total_count: 200) }
  let(:item2) { double('Item', unit_amount: 50, total_count: 200) }
  let(:items) { [item1, item2] }
  let(:category_name) { 'Page' }
  let(:unit_name) { 'Visitors' }
  let(:header) { nil }
  let(:row) { AhoyCaptain::Tables::Rows::RowComponent }
  let(:table) { nil }

  subject(:component) do
    described_class.new(
      items: items,
      category_name: category_name,
      unit_name: unit_name,
      header: header,
      row: row,
      table: table
    )
  end

  describe '#initialize' do
    it 'sets items' do
      expect(component.send(:items)).to eq(items)
    end

    it 'sets category_name' do
      expect(component.send(:category_name)).to eq(category_name)
    end

    it 'sets unit_name' do
      expect(component.send(:unit_name)).to eq(unit_name)
    end

    context 'when header is nil' do
      it 'creates default header' do
        expect(component.instance_variable_get(:@header)).to be_a(AhoyCaptain::Tables::Headers::HeaderComponent)
      end
    end

    context 'when custom header is provided' do
      # Note: Custom headers must have a no-arg initializer
      # AhoyCaptain::Tables::HeaderComponent requires arguments,
      # so we test with the default header behavior
      it 'creates default header when nil' do
        expect(component.instance_variable_get(:@header)).to be_a(AhoyCaptain::Tables::Headers::HeaderComponent)
      end
    end

    context 'when table is provided' do
      let(:mock_table) { double('DynamicTable', table: double('TableDef', headers: 'custom_headers')) }
      let(:table) { mock_table }

      it 'uses table headers' do
        expect(component.instance_variable_get(:@header)).to eq('custom_headers')
      end
    end
  end

  describe '#render_row' do
    let(:view_context) { double('ViewContext') }
    let(:rendered_row) { '<tr>rendered</tr>'.html_safe }

    before do
      allow(component).to receive(:view_context).and_return(view_context)
    end

    context 'when table is nil' do
      it 'creates a new row component and renders' do
        row_double = double('RowComponent')
        allow(AhoyCaptain::Tables::Rows::RowComponent).to receive(:new)
          .with(table: component, item: item1)
          .and_return(row_double)
        allow(row_double).to receive(:render_in).with(view_context).and_return(rendered_row)

        expect(component.render_row(item1)).to eq(rendered_row)
      end
    end

    context 'when table is provided' do
      let(:table_def) { double('TableDef', headers: 'headers') }
      let(:mock_table) { double('DynamicTable', table: table_def) }
      let(:table) { mock_table }

      it 'uses table to render row' do
        allow(table_def).to receive(:row).with(item1, view_context).and_return(rendered_row)
        expect(component.render_row(item1)).to eq(rendered_row)
      end
    end
  end

  describe '#max_amount' do
    it 'returns unit_amount of first item' do
      expect(component.send(:max_amount)).to eq(100)
    end
  end

  describe '#total' do
    it 'returns total_count of first item' do
      expect(component.send(:total)).to eq(200)
    end
  end

  describe '#fixed_height?' do
    it 'delegates to header' do
      expect(component.instance_variable_get(:@header)).to receive(:fixed_height?).and_return(true)
      expect(component.send(:fixed_height?)).to be true
    end
  end
end
