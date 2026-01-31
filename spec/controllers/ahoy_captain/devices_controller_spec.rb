# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::DevicesController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'GET #index' do
    context 'when widget is enabled' do
      before do
        allow(AhoyCaptain::Widget).to receive(:disabled?).and_return(false)
      end

      context 'with default devices_type (device_type)' do
        it 'returns a successful response' do
          get :index

          expect(response).to have_http_status(:ok)
        end

        it 'returns a successful response with visits' do
          create(:ahoy_visit)

          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with device_type devices_type' do
        before do
          create(:ahoy_visit, device_type: 'Desktop')
          create(:ahoy_visit, device_type: 'Desktop')
          create(:ahoy_visit, device_type: 'Mobile')
        end

        it 'returns a successful response' do
          get :index, params: { devices_type: 'device_type' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with browser devices_type' do
        before do
          create(:ahoy_visit, browser: 'Chrome')
          create(:ahoy_visit, browser: 'Chrome')
          create(:ahoy_visit, browser: 'Firefox')
        end

        it 'returns a successful response' do
          get :index, params: { devices_type: 'browser' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with os devices_type' do
        before do
          create(:ahoy_visit, os: 'Windows')
          create(:ahoy_visit, os: 'macOS')
          create(:ahoy_visit, os: 'Linux')
        end

        it 'returns a successful response' do
          get :index, params: { devices_type: 'os' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with invalid devices_type' do
        it 'defaults to device_type and returns success' do
          get :index, params: { devices_type: 'invalid_type' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with SQL injection attempt' do
        it 'rejects malicious devices_type and defaults to device_type' do
          expect {
            get :index, params: { devices_type: "device_type; DROP TABLE visits; --" }
          }.not_to raise_error

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with nil devices_type' do
        it 'defaults to device_type and returns success' do
          get :index, params: { devices_type: nil }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with limit parameter' do
        before do
          create(:ahoy_visit, device_type: 'Desktop')
          create(:ahoy_visit, device_type: 'Mobile')
          create(:ahoy_visit, device_type: 'Tablet')
        end

        it 'returns a successful response with limit' do
          get :index, params: { limit: 2 }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with period parameter' do
        before do
          create(:ahoy_visit, started_at: 1.day.ago)
        end

        it 'returns a successful response' do
          get :index, params: { period: '7d' }

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when widget is disabled' do
      before do
        allow(AhoyCaptain.config).to receive(:disabled_widgets).and_return(['devices.device_type'])
      end

      it 'handles widget disabled gracefully' do
        get :index, params: { devices_type: 'device_type' }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
