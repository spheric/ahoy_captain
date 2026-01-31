# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Tables::DynamicTableComponent, type: :component do
  describe '.build' do
    let(:klass) { Class.new }

    it 'creates a DynamicTableComponent instance' do
      component = described_class.build(klass) do
        column :name, title: 'Name'
      end

      expect(component).to be_a(described_class)
    end

    it 'handles fixed_height option' do
      component = described_class.build(klass, fixed_height: false) do
        column :name, title: 'Name'
      end

      headers = component.headers
      expect(headers.fixed_height?).to be false
    end
  end

  describe '#initialize' do
    let(:klass) { Class.new }
    let(:table_def) { double('TableDefinition', rows: []) }

    subject(:component) do
      described_class.new(klass, table_def, {})
    end

    it 'sets klass' do
      expect(component.instance_variable_get(:@klass)).to eq(klass)
    end

    it 'sets table' do
      expect(component.instance_variable_get(:@table)).to eq(table_def)
    end

    it 'sets options' do
      expect(component.instance_variable_get(:@options)).to eq({})
    end
  end

  describe '#for' do
    let(:klass) { Class.new }
    let(:table_def) { double('TableDefinition', rows: []) }
    let(:item) { double('Item') }

    subject(:component) do
      described_class.new(klass, table_def, {})
    end

    it 'sets item and returns self' do
      result = component.for(item)
      expect(component.instance_variable_get(:@item)).to eq(item)
      expect(result).to eq(component)
    end
  end

  describe '#row' do
    let(:klass) { Class.new }
    let(:table_def) { double('TableDefinition', rows: []) }
    let(:view_context) { double('ViewContext') }
    let(:item) { double('Item') }

    subject(:component) do
      described_class.new(klass, table_def, {})
    end

    it 'delegates to table_def.row' do
      expect(table_def).to receive(:row).with(item, view_context)
      component.row(item, view_context)
    end
  end

  describe '#headers' do
    let(:klass) { Class.new }
    let(:row1) { double('Row', header: 'Name') }
    let(:row2) { double('Row', header: 'Count') }
    let(:table_def) { double('TableDefinition', rows: [row1, row2]) }

    subject(:component) do
      described_class.new(klass, table_def, {})
    end

    it 'returns HeaderComponent with row headers' do
      headers = component.headers
      expect(headers).to be_a(AhoyCaptain::Tables::HeaderComponent)
    end

    context 'with header_options' do
      subject(:component) do
        described_class.new(klass, table_def, header_options: { fixed_height: false })
      end

      it 'passes header_options to HeaderComponent' do
        headers = component.headers
        expect(headers.fixed_height?).to be false
      end
    end
  end

  describe 'TableDefinition' do
    let(:klass) { Class.new }
    let(:table_def) { described_class::TableDefinition.new(klass) }

    describe '#column' do
      it 'adds a row' do
        table_def.column(:name, title: 'Name')
        expect(table_def.rows.size).to eq(1)
      end

      it 'returns self for chaining' do
        result = table_def.column(:name, title: 'Name')
        expect(result).to eq(table_def)
      end
    end

    describe '#progress_bar' do
      it 'adds a progress bar row' do
        table_def.progress_bar(:name, value: :count, max: :total, title: 'Name')
        expect(table_def.rows.size).to eq(1)
      end

      it 'validates options' do
        expect {
          table_def.progress_bar(:name, invalid: true, title: 'Name')
        }.to raise_error(ArgumentError)
      end
    end

    describe '#number' do
      it 'adds a number row with formatter' do
        table_def.number(:count, title: 'Count')
        row = table_def.rows.first
        expect(row.instance_variable_get(:@options)[:formatter]).to eq(:number_to_human)
      end
    end

    describe '#percent' do
      it 'adds a percent row with formatter' do
        table_def.percent(:percentage, title: 'Percent')
        row = table_def.rows.first
        expect(row.instance_variable_get(:@options)[:formatter]).to eq(:number_to_percentage)
      end
    end

    describe '#row' do
      let(:view_context) { double('ViewContext') }
      let(:item) { double('Item', name: 'Test') }

      before do
        table_def.column(:name, title: 'Name')
        allow(view_context).to receive(:content_tag).and_return('<span>Test</span>'.html_safe)
      end

      it 'renders all rows for item' do
        result = table_def.row(item, view_context)
        expect(result).to be_html_safe
      end
    end
  end

  describe 'TableDefinition::Row' do
    let(:klass) { Class.new }
    let(:view_context) { double('ViewContext') }
    let(:item) { double('Item', name: 'Test', count: 100) }

    describe '#header' do
      it 'returns title from options' do
        row = described_class::TableDefinition::Row.new(:name, title: 'Custom Title')
        expect(row.header).to eq('Custom Title')
      end

      it 'titleizes attribute when no title provided' do
        row = described_class::TableDefinition::Row.new(:display_name, {})
        expect(row.header).to eq('Display Name')
      end
    end

    describe '#render' do
      before do
        allow(view_context).to receive(:content_tag).and_return('<span>Test</span>'.html_safe)
      end

      it 'calls column for non-progress_bar types' do
        row = described_class::TableDefinition::Row.new(:name, {})
        result = row.render(item, view_context)
        expect(result).to be_html_safe
      end

      context 'with block' do
        it 'uses block value' do
          row = described_class::TableDefinition::Row.new(:name, {}) { |i| i.name.upcase }
          result = row.render(item, view_context)
          expect(result).to be_html_safe
        end
      end
    end

    describe '#build_option' do
      let(:row) { described_class::TableDefinition::Row.new(:name, {}) }

      it 'calls method when value is symbol' do
        expect(row.build_option(item, :count)).to eq(100)
      end

      it 'returns value when not a symbol' do
        expect(row.build_option(item, 50)).to eq(50)
      end
    end
  end
end
