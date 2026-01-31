# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Tables::DynamicTable, type: :component do
  describe '.register' do
    it 'creates a table definition' do
      klass = Class.new(described_class) do
        register do
          column :name, title: 'Name'
        end
      end

      expect(klass.table).to be_a(AhoyCaptain::Tables::DynamicTableComponent)
    end

    it 'memoizes the table' do
      klass = Class.new(described_class) do
        register do
          column :name, title: 'Name'
        end
      end

      expect(klass.table).to eq(klass.table)
    end
  end

  describe '.table' do
    it 'returns the registered table' do
      klass = Class.new(described_class) do
        register do
          column :name, title: 'Name'
          number :count, title: 'Count'
        end
      end

      expect(klass.table).to be_a(AhoyCaptain::Tables::DynamicTableComponent)
    end
  end
end
