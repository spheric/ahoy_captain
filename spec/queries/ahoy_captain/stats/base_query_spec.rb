# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Stats::BaseQuery do
  describe 'inheritance' do
    it 'inherits from ApplicationQuery' do
      expect(described_class.superclass).to eq(AhoyCaptain::ApplicationQuery)
    end
  end

  describe 'included modules' do
    it 'includes ComparableQuery' do
      expect(described_class.included_modules).to include(AhoyCaptain::ComparableQuery)
    end

    it 'includes LazyComparableQuery' do
      expect(described_class.included_modules).to include(AhoyCaptain::LazyComparableQuery)
    end
  end

  describe '.cast_type' do
    it 'returns the ActiveRecord type for a visit column' do
      type = described_class.cast_type(:started_at)

      expect(type).to be_a(ActiveRecord::Type::Value)
    end

    it 'returns the correct type for string columns' do
      type = described_class.cast_type(:browser)

      expect(type).to be_a(ActiveRecord::Type::String)
    end
  end

  describe '.cast_value' do
    it 'casts values using the provided type' do
      type = ActiveRecord::Type.lookup(:integer)
      result = described_class.cast_value(type, '42')

      expect(result).to eq(42)
    end

    it 'casts string values' do
      type = ActiveRecord::Type.lookup(:string)
      result = described_class.cast_value(type, 123)

      expect(result).to eq('123')
    end
  end
end
