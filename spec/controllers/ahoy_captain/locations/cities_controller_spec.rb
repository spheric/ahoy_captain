# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Locations::CitiesController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'GET #index' do
    context 'when widget is enabled' do
      before do
        allow(AhoyCaptain::Widget).to receive(:disabled?).with(:locations, :cities).and_return(false)
      end

      context 'with no visits' do
        it 'returns http success' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with visits that have city data' do
        before do
          create(:ahoy_visit, city: 'San Francisco', region: 'California', country: 'US')
          create(:ahoy_visit, city: 'New York', region: 'New York', country: 'US')
          create(:ahoy_visit, city: 'San Francisco', region: 'California', country: 'US')
        end

        it 'returns http success' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with visits that have nil city' do
        before do
          create(:ahoy_visit, city: nil, region: 'Unknown', country: 'US')
          create(:ahoy_visit, city: 'Boston', region: 'Massachusetts', country: 'US')
        end

        it 'returns http success' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with limit parameter' do
        before do
          create(:ahoy_visit, city: 'City1', region: 'Region1', country: 'US')
          create(:ahoy_visit, city: 'City2', region: 'Region2', country: 'US')
          create(:ahoy_visit, city: 'City3', region: 'Region3', country: 'US')
        end

        it 'returns http success with limit' do
          get :index, params: { limit: 2 }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with period parameter' do
        before do
          create(:ahoy_visit, city: 'Test City', region: 'Test Region', country: 'US', started_at: 1.day.ago)
        end

        it 'returns http success' do
          get :index, params: { period: '7d' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with details variant' do
        before do
          create(:ahoy_visit, city: 'Test City', region: 'Test Region', country: 'US')
          request.headers['Turbo-Frame'] = 'details'
        end

        it 'returns http success' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when widget is disabled' do
      before do
        allow(AhoyCaptain.config).to receive(:disabled_widgets).and_return(['locations.cities'])
      end

      it 'handles widget disabled gracefully' do
        get :index

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
