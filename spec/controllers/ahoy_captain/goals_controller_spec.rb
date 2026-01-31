# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::GoalsController, type: :controller do
  routes { AhoyCaptain::Engine.routes }
  render_views

  describe 'GET #index' do
    before do
      request.headers['Turbo-Frame'] = 'goals'
    end

    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:ok)
    end

    it 'returns HTML response' do
      get :index

      expect(response.media_type).to eq('text/html')
    end

    it 'includes turbo frame tag for goals' do
      get :index

      expect(response.body).to include('turbo-frame')
      expect(response.body).to include('id="goals"')
    end

    context 'with period parameter' do
      it 'accepts day period' do
        get :index, params: { period: 'day' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts week period' do
        get :index, params: { period: '7d' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts month period' do
        get :index, params: { period: '30d' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with ransack query parameters on visit' do
      let!(:visit) { create(:ahoy_visit, country: 'United States') }

      before do
        create(:ahoy_event, visit: visit, time: Time.current)
      end

      it 'filters events based on query params' do
        get :index, params: { q: { country_eq: 'United States' } }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with configured goals' do
      let!(:visit) { create(:ahoy_visit) }

      before do
        # Configure a test goal
        goal = AhoyCaptain::Goal.new
        goal.id = :test_purchase
        goal.label('Test Purchase')
        goal.name('purchase')
        AhoyCaptain.config.goals.register(goal)

        create(:ahoy_event, :custom_event, visit: visit, event_name: 'purchase', time: Time.current)
      end

      it 'returns success with goals data' do
        get :index

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
