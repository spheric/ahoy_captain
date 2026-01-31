# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::SourcesController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'GET #index' do
    context 'when widget is enabled' do
      before do
        allow(AhoyCaptain::Widget).to receive(:disabled?).with(:sources).and_return(false)
      end

      it 'returns a successful response' do
        get :index

        expect(response).to have_http_status(:ok)
      end

      context 'with visits having referring domains' do
        before do
          create(:ahoy_visit, referring_domain: 'google.com')
          create(:ahoy_visit, referring_domain: 'google.com')
          create(:ahoy_visit, referring_domain: 'facebook.com')
        end

        it 'returns a successful response' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with no referring domains' do
        before do
          create(:ahoy_visit, referring_domain: nil)
        end

        it 'returns a successful response' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with limit parameter' do
        before do
          create(:ahoy_visit, referring_domain: 'google.com')
          create(:ahoy_visit, referring_domain: 'facebook.com')
          create(:ahoy_visit, referring_domain: 'twitter.com')
        end

        it 'returns a successful response with limit' do
          get :index, params: { limit: 2 }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with period parameter' do
        before do
          create(:ahoy_visit, referring_domain: 'google.com', started_at: 1.day.ago)
        end

        it 'returns a successful response' do
          get :index, params: { period: '7d' }

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when widget is disabled' do
      before do
        allow(AhoyCaptain.config).to receive(:disabled_widgets).and_return(['sources'])
      end

      it 'handles widget disabled gracefully' do
        get :index

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
