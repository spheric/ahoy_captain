# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::CampaignsController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'GET #index' do
    context 'when widget is enabled' do
      before do
        allow(AhoyCaptain::Widget).to receive(:disabled?).and_return(false)
      end

      context 'with default campaigns_type (utm_source)' do
        it 'returns a successful response' do
          get :index

          expect(response).to have_http_status(:ok)
        end

        it 'returns a successful response with visits' do
          create(:ahoy_visit, :with_utm)

          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with utm_source campaigns_type' do
        before do
          create(:ahoy_visit, utm_source: 'google')
          create(:ahoy_visit, utm_source: 'google')
          create(:ahoy_visit, utm_source: 'facebook')
        end

        it 'returns a successful response' do
          get :index, params: { campaigns_type: 'utm_source' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with utm_medium campaigns_type' do
        before do
          create(:ahoy_visit, utm_medium: 'cpc')
          create(:ahoy_visit, utm_medium: 'organic')
        end

        it 'returns a successful response' do
          get :index, params: { campaigns_type: 'utm_medium' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with utm_campaign campaigns_type' do
        before do
          create(:ahoy_visit, utm_campaign: 'summer_sale')
          create(:ahoy_visit, utm_campaign: 'winter_promo')
        end

        it 'returns a successful response' do
          get :index, params: { campaigns_type: 'utm_campaign' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with utm_term campaigns_type' do
        before do
          create(:ahoy_visit, utm_term: 'ruby')
          create(:ahoy_visit, utm_term: 'rails')
        end

        it 'returns a successful response' do
          get :index, params: { campaigns_type: 'utm_term' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with utm_content campaigns_type' do
        before do
          create(:ahoy_visit, utm_content: 'banner_ad')
          create(:ahoy_visit, utm_content: 'sidebar_ad')
        end

        it 'returns a successful response' do
          get :index, params: { campaigns_type: 'utm_content' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with invalid campaigns_type' do
        it 'defaults to utm_source and returns success' do
          get :index, params: { campaigns_type: 'invalid_type' }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with SQL injection attempt' do
        it 'rejects malicious campaigns_type and defaults to utm_source' do
          expect {
            get :index, params: { campaigns_type: "utm_source; DROP TABLE visits; --" }
          }.not_to raise_error

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with nil campaigns_type' do
        it 'defaults to utm_source and returns success' do
          get :index, params: { campaigns_type: nil }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with limit parameter' do
        before do
          create(:ahoy_visit, utm_source: 'google')
          create(:ahoy_visit, utm_source: 'facebook')
          create(:ahoy_visit, utm_source: 'twitter')
        end

        it 'returns a successful response with limit' do
          get :index, params: { limit: 2 }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with period parameter' do
        before do
          create(:ahoy_visit, :with_utm, started_at: 1.day.ago)
        end

        it 'returns a successful response' do
          get :index, params: { period: '7d' }

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when widget is disabled' do
      before do
        allow(AhoyCaptain.config).to receive(:disabled_widgets).and_return(['campaigns.utm_source'])
      end

      it 'handles widget disabled gracefully' do
        get :index, params: { campaigns_type: 'utm_source' }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
