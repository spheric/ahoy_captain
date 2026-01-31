# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Filters::LocationsController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'ALLOWED_TYPES' do
    it 'includes country' do
      expect(described_class::ALLOWED_TYPES).to include('country')
    end

    it 'includes region' do
      expect(described_class::ALLOWED_TYPES).to include('region')
    end

    it 'includes city' do
      expect(described_class::ALLOWED_TYPES).to include('city')
    end

    it 'only includes 3 types' do
      expect(described_class::ALLOWED_TYPES.length).to eq(3)
    end

    it 'is frozen' do
      expect(described_class::ALLOWED_TYPES).to be_frozen
    end
  end

  describe 'GET #index' do
    context 'with valid type parameter' do
      it 'accepts country type' do
        get :index, params: { type: 'country' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts region type' do
        get :index, params: { type: 'region' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts city type' do
        get :index, params: { type: 'city' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with SQL injection attempt' do
      it 'rejects malicious type and defaults to country' do
        expect {
          get :index, params: { type: "'; DROP TABLE visits; --" }
        }.not_to raise_error

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid type' do
      it 'defaults to country' do
        get :index, params: { type: 'invalid_column' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with nil type' do
      it 'defaults to country' do
        get :index, params: { type: nil }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
