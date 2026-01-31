# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Rangeable do
  let(:test_class) do
    Class.new do
      include AhoyCaptain::Rangeable

      attr_reader :params

      def initialize(params = {})
        @params = params
      end
    end
  end

  describe '#period' do
    context 'when params includes period' do
      it 'returns the period from params' do
        instance = test_class.new(period: '7d')

        expect(instance.period).to eq('7d')
      end

      it 'returns the period as-is when it is a symbol' do
        instance = test_class.new(period: :'30d')

        expect(instance.period).to eq(:'30d')
      end
    end

    context 'when params does not include period' do
      it 'returns the default period from config' do
        instance = test_class.new({})

        expect(instance.period).to eq(AhoyCaptain.config.ranges.default)
      end
    end

    context 'when period is nil' do
      it 'returns the default period from config' do
        instance = test_class.new(period: nil)

        expect(instance.period).to eq(AhoyCaptain.config.ranges.default)
      end
    end

    context 'when params is empty' do
      it 'returns the default period from config' do
        instance = test_class.new

        expect(instance.period).to eq(AhoyCaptain.config.ranges.default)
      end
    end
  end

  describe 'default configuration' do
    it 'has a default period configured' do
      expect(AhoyCaptain.config.ranges.default).not_to be_nil
    end

    it 'default period is :30d' do
      expect(AhoyCaptain.config.ranges.default).to eq(:'30d')
    end
  end
end
