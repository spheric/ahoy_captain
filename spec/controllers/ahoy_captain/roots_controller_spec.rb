# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::RootsController, type: :controller do
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
  end
end
