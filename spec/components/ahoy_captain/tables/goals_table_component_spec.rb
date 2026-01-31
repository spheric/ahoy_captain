# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Tables::GoalsTableComponent, type: :component do
  describe '.table' do
    it 'returns a registered table' do
      expect(described_class.table).to be_a(AhoyCaptain::Tables::DynamicTableComponent)
    end

    it 'has appropriate headers' do
      headers = described_class.table.headers
      header_list = headers.instance_variable_get(:@headers)
      labels = header_list.map { |h| h[:label] }
      expect(labels).to include('Name', 'Uniques', 'Total', 'CR')
    end

    it 'has fixed_height set to false' do
      headers = described_class.table.headers
      expect(headers.fixed_height?).to be false
    end
  end
end
