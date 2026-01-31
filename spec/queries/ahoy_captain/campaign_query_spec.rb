# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::CampaignQuery do
  describe 'ALLOWED_CAMPAIGN_TYPES' do
    it 'includes utm_source' do
      expect(described_class::ALLOWED_CAMPAIGN_TYPES).to include('utm_source')
    end

    it 'includes utm_medium' do
      expect(described_class::ALLOWED_CAMPAIGN_TYPES).to include('utm_medium')
    end

    it 'includes utm_term' do
      expect(described_class::ALLOWED_CAMPAIGN_TYPES).to include('utm_term')
    end

    it 'includes utm_content' do
      expect(described_class::ALLOWED_CAMPAIGN_TYPES).to include('utm_content')
    end

    it 'includes utm_campaign' do
      expect(described_class::ALLOWED_CAMPAIGN_TYPES).to include('utm_campaign')
    end

    it 'only includes 5 types' do
      expect(described_class::ALLOWED_CAMPAIGN_TYPES.length).to eq(5)
    end

    it 'is frozen' do
      expect(described_class::ALLOWED_CAMPAIGN_TYPES).to be_frozen
    end
  end

  describe '#build' do
    let(:base_params) do
      {
        start_date: 30.days.ago,
        end_date: Time.current,
        period: '30d',
        controller: 'ahoy_captain/campaigns'
      }
    end

    context 'with valid campaign type' do
      let(:params) { base_params.merge(campaigns_type: 'utm_source') }

      it 'uses the specified campaign type' do
        result = described_class.call(params)

        expect(result.to_sql).to include('utm_source')
      end
    end

    context 'with another valid campaign type' do
      let(:params) { base_params.merge(campaigns_type: 'utm_campaign') }

      it 'uses the specified campaign type' do
        result = described_class.call(params)

        expect(result.to_sql).to include('utm_campaign')
      end
    end

    context 'with SQL injection attempt' do
      let(:params) { base_params.merge(campaigns_type: "'; DROP TABLE users; --") }

      it 'defaults to utm_source' do
        result = described_class.call(params)
        sql = result.to_sql

        expect(sql).to include('utm_source')
        expect(sql).not_to include('DROP TABLE')
      end
    end

    context 'with invalid campaign type' do
      let(:params) { base_params.merge(campaigns_type: 'invalid_column') }

      it 'defaults to utm_source' do
        result = described_class.call(params)

        expect(result.to_sql).to include('utm_source')
        expect(result.to_sql).not_to include('invalid_column')
      end
    end

    context 'with nil campaign type' do
      let(:params) { base_params.merge(campaigns_type: nil) }

      it 'defaults to utm_source' do
        result = described_class.call(params)

        expect(result.to_sql).to include('utm_source')
      end
    end

    context 'with empty string campaign type' do
      let(:params) { base_params.merge(campaigns_type: '') }

      it 'defaults to utm_source' do
        result = described_class.call(params)

        expect(result.to_sql).to include('utm_source')
      end
    end
  end
end
