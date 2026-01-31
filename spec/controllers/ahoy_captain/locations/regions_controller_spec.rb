# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Locations::RegionsController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'GET #index' do
    context 'when widget is enabled' do
      before do
        allow(AhoyCaptain::Widget).to receive(:disabled?).with(:locations, :regions).and_return(false)
      end

      context 'with no visits' do
        it 'returns http success' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with visits that have region data' do
        before do
          create(:ahoy_visit, region: 'California', country: 'US')
          create(:ahoy_visit, region: 'New York', country: 'US')
          create(:ahoy_visit, region: 'California', country: 'US')
        end

        it 'returns http success' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with visits that have nil region' do
        before do
          create(:ahoy_visit, region: nil, country: 'US')
          create(:ahoy_visit, region: 'Texas', country: 'US')
        end

        it 'returns http success' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with limit parameter' do
        before do
          create(:ahoy_visit, region: 'Region1', country: 'US')
          create(:ahoy_visit, region: 'Region2', country: 'US')
          create(:ahoy_visit, region: 'Region3', country: 'US')
        end

        it 'returns http success with limit' do
          get :index, params: { limit: 2 }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with period parameter' do
        before do
          create(:ahoy_visit, region: 'Test Region', country: 'US', started_at: 1.day.ago)
        end

        it 'returns http success' do
          get :index, params: { period: '7d' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with details variant' do
        before do
          create(:ahoy_visit, region: 'Test Region', country: 'US')
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
        allow(AhoyCaptain.config).to receive(:disabled_widgets).and_return(['locations.regions'])
      end

      it 'handles widget disabled gracefully' do
        get :index

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
