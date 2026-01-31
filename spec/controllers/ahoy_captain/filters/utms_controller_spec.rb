# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Filters::UtmsController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'ALLOWED_TYPES' do
    it 'includes utm_source' do
      expect(described_class::ALLOWED_TYPES).to include('utm_source')
    end

    it 'includes utm_medium' do
      expect(described_class::ALLOWED_TYPES).to include('utm_medium')
    end

    it 'includes utm_term' do
      expect(described_class::ALLOWED_TYPES).to include('utm_term')
    end

    it 'includes utm_content' do
      expect(described_class::ALLOWED_TYPES).to include('utm_content')
    end

    it 'includes utm_campaign' do
      expect(described_class::ALLOWED_TYPES).to include('utm_campaign')
    end

    it 'only includes 5 types' do
      expect(described_class::ALLOWED_TYPES.length).to eq(5)
    end

    it 'is frozen' do
      expect(described_class::ALLOWED_TYPES).to be_frozen
    end
  end

  describe 'GET #index' do
    context 'with valid type parameter' do
      it 'accepts utm_source type' do
        get :index, params: { type: 'utm_source' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts utm_campaign type' do
        get :index, params: { type: 'utm_campaign' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with SQL injection attempt' do
      it 'rejects malicious type and defaults to utm_source' do
        expect {
          get :index, params: { type: "utm_source; DROP TABLE visits; --" }
        }.not_to raise_error

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid type' do
      it 'defaults to utm_source' do
        get :index, params: { type: 'malicious_column' }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
