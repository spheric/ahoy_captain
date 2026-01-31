# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::FunnelsController, type: :controller do
  routes { AhoyCaptain::Engine.routes }
  render_views

  let(:funnel_id) { :test_funnel }

  before do
    request.headers['Turbo-Frame'] = 'goals'

    # Set up test goals first
    goal1 = AhoyCaptain::Goal.new
    goal1.id = :step_one
    goal1.label('Step One')
    goal1.name('step_one_event')
    AhoyCaptain.config.goals.register(goal1)

    goal2 = AhoyCaptain::Goal.new
    goal2.id = :step_two
    goal2.label('Step Two')
    goal2.name('step_two_event')
    AhoyCaptain.config.goals.register(goal2)

    # Set up test funnel
    funnel = AhoyCaptain::Funnel.new
    funnel.id = :test_funnel
    funnel.instance_eval do
      label 'Test Funnel'
      goal :step_one
      goal :step_two
    end
    AhoyCaptain.configuration.funnels.register(funnel)
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: funnel_id }

      expect(response).to have_http_status(:ok)
    end

    it 'returns HTML response' do
      get :show, params: { id: funnel_id }

      expect(response.media_type).to eq('text/html')
    end

    it 'includes turbo frame tag for goals' do
      get :show, params: { id: funnel_id }

      expect(response.body).to include('turbo-frame')
      expect(response.body).to include('id="goals"')
    end

    context 'with funnel data' do
      let!(:visit) { create(:ahoy_visit) }

      before do
        create(:ahoy_event, :custom_event, visit: visit, event_name: 'step_one_event', time: Time.current)
        create(:ahoy_event, :custom_event, visit: visit, event_name: 'step_two_event', time: Time.current)
      end

      it 'returns success with funnel steps' do
        get :show, params: { id: funnel_id }

        expect(response).to have_http_status(:ok)
      end

      it 'includes funnel chart data' do
        get :show, params: { id: funnel_id }

        expect(response.body).to include('funnel-chart')
      end
    end

    context 'with period parameter' do
      it 'accepts day period' do
        get :show, params: { id: funnel_id, period: 'day' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts week period' do
        get :show, params: { id: funnel_id, period: '7d' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts month period' do
        get :show, params: { id: funnel_id, period: '30d' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with ransack query parameters on visit' do
      let!(:visit) { create(:ahoy_visit, country: 'United States') }

      before do
        create(:ahoy_event, :custom_event, visit: visit, event_name: 'step_one_event', time: Time.current)
      end

      it 'filters events based on query params' do
        get :show, params: { id: funnel_id, q: { country_eq: 'United States' } }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with different funnel id' do
      let!(:another_funnel) do
        funnel = AhoyCaptain::Funnel.new
        funnel.id = :another_funnel
        funnel.instance_eval do
          label 'Another Funnel'
          goal :step_one
        end
        AhoyCaptain.configuration.funnels.register(funnel)
        funnel
      end

      it 'loads the correct funnel' do
        get :show, params: { id: :another_funnel }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('funnel-chart')
      end
    end
  end
end
