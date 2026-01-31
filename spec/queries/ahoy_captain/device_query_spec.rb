# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::DeviceQuery do
  describe 'ALLOWED_DEVICE_TYPES' do
    it 'includes browser' do
      expect(described_class::ALLOWED_DEVICE_TYPES).to include('browser')
    end

    it 'includes os' do
      expect(described_class::ALLOWED_DEVICE_TYPES).to include('os')
    end

    it 'includes device_type' do
      expect(described_class::ALLOWED_DEVICE_TYPES).to include('device_type')
    end

    it 'only includes 3 types' do
      expect(described_class::ALLOWED_DEVICE_TYPES.length).to eq(3)
    end

    it 'is frozen' do
      expect(described_class::ALLOWED_DEVICE_TYPES).to be_frozen
    end
  end

  describe '#build' do
    subject(:query) { described_class.new(params) }

    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d'
      }
    end

    context 'with valid device type' do
      let(:params) { base_params.merge(devices_type: 'browser') }

      it 'uses the specified device type' do
        result = query.call

        expect(result.to_sql).to include('browser')
      end
    end

    context 'with os device type' do
      let(:params) { base_params.merge(devices_type: 'os') }

      it 'uses the specified device type' do
        result = query.call

        expect(result.to_sql).to include('"os"')
      end
    end

    context 'with SQL injection attempt' do
      let(:params) { base_params.merge(devices_type: "'; DROP TABLE visits; --") }

      it 'defaults to device_type' do
        result = query.call
        sql = result.to_sql

        expect(sql).to include('device_type')
        expect(sql).not_to include('DROP TABLE')
      end
    end

    context 'with invalid device type' do
      let(:params) { base_params.merge(devices_type: 'hacked_column') }

      it 'defaults to device_type' do
        result = query.call

        expect(result.to_sql).to include('device_type')
        expect(result.to_sql).not_to include('hacked_column')
      end
    end

    context 'with nil device type' do
      let(:params) { base_params.merge(devices_type: nil) }

      it 'defaults to device_type' do
        result = query.call

        expect(result.to_sql).to include('device_type')
      end
    end
  end
end
