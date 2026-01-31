# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Filters::Properties::ValuesController, type: :controller do
  routes { AhoyCaptain::Engine.routes }

  describe 'GET #index' do
    context 'with valid property key' do
      it 'accepts alphanumeric keys with underscores' do
        get :index, params: { q: { "properties.valid_key_123_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'accepts keys starting with letter' do
        get :index, params: { q: { "properties.myProperty_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'accepts keys starting with underscore' do
        get :index, params: { q: { "properties._private_key_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with SQL injection attempts' do
      it 'rejects key with SQL injection and returns empty array' do
        get :index, params: { q: { "properties.'; DROP TABLE events; --_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'rejects key with semicolon' do
        get :index, params: { q: { "properties.key; DELETE FROM events_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'rejects key with quotes' do
        get :index, params: { q: { "properties.key'OR'1'='1_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'rejects key with double quotes' do
        get :index, params: { q: { 'properties.key"OR"1"="1_i_cont' => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'rejects key with parentheses' do
        get :index, params: { q: { "properties.key()_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'rejects key with comment syntax' do
        get :index, params: { q: { "properties.key/*comment*/_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'rejects key with hyphen' do
        get :index, params: { q: { "properties.key-name_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'rejects key starting with number' do
        get :index, params: { q: { "properties.123key_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end
    end

    context 'with nil/empty handling' do
      it 'returns empty array when no q param' do
        get :index, params: {}, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'returns empty array when q is empty' do
        get :index, params: { q: {} }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'returns empty array when no properties key found' do
        get :index, params: { q: { "other_field_i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

      it 'returns empty array when key is empty string' do
        get :index, params: { q: { "properties._i_cont" => "test" } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end
    end

    context 'key sanitization regex validation' do
      it 'validates key format with /\A[a-zA-Z_][a-zA-Z0-9_]*\z/' do
        valid_keys = %w[key Key KEY key123 key_name _key __key key_123_name]

        valid_keys.each do |key|
          expect(key).to match(/\A[a-zA-Z_][a-zA-Z0-9_]*\z/), "Expected '#{key}' to be valid"
        end
      end

      it 'rejects invalid key formats' do
        invalid_keys = [
          "123key",
          "key-name",
          "key.name",
          "key name",
          "key;name",
          "key'name",
          "",
          "key()",
        ]

        invalid_keys.each do |key|
          expect(key).not_to match(/\A[a-zA-Z_][a-zA-Z0-9_]*\z/), "Expected '#{key}' to be invalid"
        end
      end
    end
  end
end
