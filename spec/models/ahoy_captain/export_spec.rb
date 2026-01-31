# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe AhoyCaptain::Export do
  let(:params) do
    {
      start_date: 30.days.ago,
      end_date: Time.current,
      period: '30d',
      controller: 'ahoy_captain/exports'
    }
  end

  let(:view_context) { double('view_context', params: params) }
  let(:request) { double('request') }
  let(:context) { double('context', view_context: view_context, request: request, params: params) }

  describe '#initialize' do
    it 'initializes with params and context' do
      export = described_class.new(params, context)

      expect(export).to be_a(described_class)
    end
  end

  describe '#build' do
    subject(:export) { described_class.new(params, context) }

    before do
      # Create test data
      visit = create(:ahoy_visit,
        browser: 'Chrome',
        os: 'macOS',
        device_type: 'Desktop',
        city: 'San Francisco',
        region: 'California',
        country: 'United States',
        landing_page: '/home',
        utm_source: 'google',
        utm_medium: 'cpc',
        utm_campaign: 'test_campaign',
        utm_term: 'test_term',
        utm_content: 'test_content',
        referring_domain: 'google.com',
        started_at: 1.day.ago
      )

      create(:ahoy_event, visit: visit, name: '$view', time: 1.day.ago, properties: {
        'controller' => 'pages',
        'action' => 'home',
        'url' => '/home'
      })
    end

    it 'returns self' do
      result = export.build

      expect(result).to eq(export)
    end

    it 'builds browsers.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('browsers.csv')
      expect(files['browsers.csv']).to be_a(String)
    end

    it 'builds cities.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('cities.csv')
    end

    it 'builds countries.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('countries.csv')
    end

    it 'builds devices.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('devices.csv')
    end

    it 'builds entry_pages.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('entry_pages.csv')
    end

    it 'builds exit_pages.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('exit_pages.csv')
    end

    it 'builds operating_systems.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('operating_systems.csv')
    end

    it 'builds top_pages.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('top_pages.csv')
    end

    it 'builds regions.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('regions.csv')
    end

    it 'builds sources.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('sources.csv')
    end

    it 'builds utm_campaigns.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('utm_campaigns.csv')
    end

    it 'builds utm_contents.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('utm_contents.csv')
    end

    it 'builds utm_media.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('utm_media.csv')
    end

    it 'builds utm_sources.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('utm_sources.csv')
    end

    it 'builds utm_terms.csv' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files).to have_key('utm_terms.csv')
    end

    it 'builds all 15 CSV files' do
      export.build

      files = export.instance_variable_get(:@files)
      expect(files.keys.count).to eq(15)
    end
  end

  describe '#to_zip' do
    subject(:export) { described_class.new(params, context) }

    before do
      visit = create(:ahoy_visit,
        browser: 'Chrome',
        city: 'San Francisco',
        region: 'California',
        country: 'United States',
        started_at: 1.day.ago
      )

      create(:ahoy_event, visit: visit, name: '$view', time: 1.day.ago, properties: {
        'controller' => 'pages',
        'action' => 'home',
        'url' => '/home'
      })
    end

    it 'returns a zip stream' do
      export.build
      zip_stream = export.to_zip

      expect(zip_stream).to respond_to(:read)
    end

    it 'creates a valid zip file with all CSV files' do
      export.build
      zip_stream = export.to_zip

      entries = []
      Zip::InputStream.open(zip_stream) do |io|
        while (entry = io.get_next_entry)
          entries << entry.name
        end
      end

      expect(entries).to include('browsers.csv')
      expect(entries).to include('cities.csv')
      expect(entries).to include('countries.csv')
      expect(entries).to include('devices.csv')
      expect(entries).to include('entry_pages.csv')
      expect(entries).to include('exit_pages.csv')
      expect(entries).to include('operating_systems.csv')
      expect(entries).to include('top_pages.csv')
      expect(entries).to include('regions.csv')
      expect(entries).to include('sources.csv')
      expect(entries).to include('utm_campaigns.csv')
      expect(entries).to include('utm_contents.csv')
      expect(entries).to include('utm_media.csv')
      expect(entries).to include('utm_sources.csv')
      expect(entries).to include('utm_terms.csv')
    end

    it 'includes CSV content in zip entries' do
      export.build
      zip_stream = export.to_zip

      content = nil
      Zip::InputStream.open(zip_stream) do |io|
        while (entry = io.get_next_entry)
          if entry.name == 'browsers.csv'
            content = io.read
            break
          end
        end
      end

      expect(content).to be_a(String)
      expect(content).to include('Total')
    end
  end

  describe 'CSV content format' do
    subject(:export) { described_class.new(params, context) }

    before do
      visit = create(:ahoy_visit,
        browser: 'Firefox',
        os: 'Windows',
        device_type: 'Desktop',
        city: 'New York',
        region: 'New York',
        country: 'United States',
        landing_page: '/products',
        utm_source: 'facebook',
        referring_domain: 'facebook.com',
        started_at: 1.day.ago
      )

      create(:ahoy_event, visit: visit, name: '$view', time: 1.day.ago, properties: {
        'controller' => 'products',
        'action' => 'index',
        'url' => '/products'
      })
    end

    it 'generates valid CSV format for browsers' do
      export.build
      files = export.instance_variable_get(:@files)
      csv_content = files['browsers.csv']

      parsed = CSV.parse(csv_content, headers: true)

      # The header column name comes from context.params[:devices_type]
      # When nil, it produces an empty string as the first header
      expect(parsed.headers).to include('Total')
      expect(parsed.to_a.length).to be > 1
    end

    it 'generates valid CSV format for devices' do
      export.build
      files = export.instance_variable_get(:@files)
      csv_content = files['devices.csv']

      parsed = CSV.parse(csv_content, headers: true)

      # The header column name comes from context.params[:devices_type]
      # When nil, it produces an empty string as the first header
      expect(parsed.headers).to include('Total')
      expect(parsed.to_a.length).to be > 1
    end

    it 'generates valid CSV format for cities' do
      export.build
      files = export.instance_variable_get(:@files)
      csv_content = files['cities.csv']

      parsed = CSV.parse(csv_content, headers: true)

      expect(parsed.headers).to include('Country')
      expect(parsed.headers).to include('City')
      expect(parsed.headers).to include('Total')
    end
  end

  describe 'private methods' do
    subject(:export) { described_class.new(params, context) }

    describe '#merged_params' do
      it 'merges additional params while preserving original' do
        merged = export.send(:merged_params, devices_type: 'browser')

        expect(merged[:devices_type]).to eq('browser')
        expect(merged[:period]).to eq('30d')
      end

      it 'does not modify original params' do
        original_params = params.dup
        export.send(:merged_params, devices_type: 'browser')

        expect(params).to eq(original_params)
      end
    end
  end
end
