# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::RealtimesController, type: :controller do
  routes { AhoyCaptain::Engine.routes }
  render_views

  describe 'GET #show' do
    before do
      request.headers['Turbo-Frame'] = 'realtime'
    end

    it 'returns http success' do
      get :show

      expect(response).to have_http_status(:ok)
    end

    context 'with no recent events' do
      it 'returns response with 0 visitors' do
        get :show

        expect(response.body).to include('0')
        expect(response.body).to include('current visitors')
      end
    end

    context 'with recent events within the last minute' do
      let!(:visit) { create(:ahoy_visit) }

      before do
        create(:ahoy_event, visit: visit, time: 30.seconds.ago)
      end

      it 'shows count of unique visitors' do
        get :show

        expect(response.body).to include('1')
        expect(response.body).to include('current visitors')
      end
    end

    context 'with multiple events from the same visit' do
      let!(:visit) { create(:ahoy_visit) }

      before do
        create(:ahoy_event, visit: visit, time: 10.seconds.ago)
        create(:ahoy_event, visit: visit, time: 20.seconds.ago)
        create(:ahoy_event, visit: visit, time: 30.seconds.ago)
      end

      it 'counts unique visitors only once' do
        get :show

        # Should still be 1 because all events are from the same visit
        expect(response.body).to match(/<a.*>.*1.*current visitors/m)
      end
    end

    context 'with multiple visits' do
      let!(:visit1) { create(:ahoy_visit) }
      let!(:visit2) { create(:ahoy_visit) }
      let!(:visit3) { create(:ahoy_visit) }

      before do
        create(:ahoy_event, visit: visit1, time: 10.seconds.ago)
        create(:ahoy_event, visit: visit2, time: 20.seconds.ago)
        create(:ahoy_event, visit: visit3, time: 30.seconds.ago)
      end

      it 'counts all unique visitors' do
        get :show

        expect(response.body).to include('3')
        expect(response.body).to include('current visitors')
      end
    end

    context 'with events older than 1 minute' do
      let!(:visit) { create(:ahoy_visit) }

      before do
        create(:ahoy_event, visit: visit, time: 2.minutes.ago)
      end

      it 'does not count old events' do
        get :show

        expect(response.body).to match(/<a.*>.*0.*current visitors/m)
      end
    end

    context 'with mixed recent and old events' do
      let!(:recent_visit) { create(:ahoy_visit) }
      let!(:old_visit) { create(:ahoy_visit) }

      before do
        create(:ahoy_event, visit: recent_visit, time: 30.seconds.ago)
        create(:ahoy_event, visit: old_visit, time: 5.minutes.ago)
      end

      it 'only counts recent visitors' do
        get :show

        expect(response.body).to match(/<a.*>.*1.*current visitors/m)
      end
    end

    context 'response format' do
      it 'returns HTML response' do
        get :show

        expect(response.media_type).to eq('text/html')
      end

      it 'includes turbo frame tag' do
        get :show

        expect(response.body).to include('turbo-frame')
        expect(response.body).to include('id="realtime"')
      end
    end
  end
end
