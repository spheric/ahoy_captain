# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Tables::DevicesTableComponent, type: :component do
  describe '.table' do
    it 'returns a registered table' do
      expect(described_class.table).to be_a(AhoyCaptain::Tables::DynamicTableComponent)
    end

    it 'has headers for display_name and count' do
      headers = described_class.table.headers
      header_list = headers.instance_variable_get(:@headers)
      labels = header_list.map { |h| h[:label] }
      expect(labels).to include('Device', 'Visitors')
    end
  end
end
