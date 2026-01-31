# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::StatsController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'GET #show' do
    it 'responds successfully' do
      get :show

      expect(response).to have_http_status(:ok)
    end

    it 'returns HTML content type' do
      get :show

      expect(response.content_type).to include('text/html')
    end

    context 'with period parameter' do
      it 'accepts day period' do
        get :show, params: { period: 'day' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts 7d period' do
        get :show, params: { period: '7d' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts 30d period' do
        get :show, params: { period: '30d' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts month period' do
        get :show, params: { period: 'month' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts 12mo period' do
        get :show, params: { period: '12mo' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with comparison parameter' do
      it 'accepts comparison=true' do
        get :show, params: { comparison: 'true' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts comparison=false' do
        get :show, params: { comparison: 'false' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with turbo frame request' do
      it 'responds to turbo frame requests' do
        request.headers['Turbo-Frame'] = 'stats'
        get :show

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with visit data' do
      before do
        create(:ahoy_visit, started_at: 1.hour.ago)
        create(:ahoy_visit, started_at: 2.hours.ago)
      end

      it 'responds successfully with data present' do
        get :show

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
