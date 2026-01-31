# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::TopPagesController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'GET #index' do
    context 'when widget is enabled' do
      before do
        allow(AhoyCaptain::Widget).to receive(:disabled?).with(:top_pages).and_return(false)
      end

      it 'returns a successful response' do
        get :index

        expect(response).to have_http_status(:ok)
      end

      context 'with page view data' do
        before do
          visit = create(:ahoy_visit, started_at: 1.day.ago)
          create(:ahoy_event, :with_url, visit: visit, url: '/home', time: 1.day.ago)
        end

        it 'returns a successful response' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with multiple page views' do
        before do
          visit1 = create(:ahoy_visit, started_at: 1.day.ago)
          visit2 = create(:ahoy_visit, started_at: 1.day.ago)

          create(:ahoy_event, :with_url, visit: visit1, url: '/home', time: 1.day.ago)
          create(:ahoy_event, :with_url, visit: visit1, url: '/about', time: 1.day.ago)
          create(:ahoy_event, :with_url, visit: visit2, url: '/home', time: 1.day.ago)
        end

        it 'returns a successful response with page data' do
          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with limit parameter' do
        before do
          visit = create(:ahoy_visit, started_at: 1.day.ago)
          5.times do |i|
            create(:ahoy_event, :with_url, visit: visit, url: "/page#{i}", time: 1.day.ago)
          end
        end

        it 'returns a successful response' do
          get :index, params: { limit: 2 }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with period parameter' do
        it 'accepts valid period parameter' do
          get :index, params: { period: '7d' }

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when widget is disabled' do
      before do
        allow(AhoyCaptain::Widget).to receive(:disabled?).with(:top_pages).and_return(true)
      end

      it 'rescues WidgetDisabled and renders widget_disabled partial' do
        get :index

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
