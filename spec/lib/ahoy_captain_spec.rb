# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain do
  # Reset module state between tests to ensure isolation
  before do
    described_class.instance_variable_set(:@configuration, nil)
    described_class.instance_variable_set(:@cache, nil)
    described_class.instance_variable_set(:@event, nil)
    described_class.instance_variable_set(:@visit, nil)
    described_class.instance_variable_set(:@none, nil)
  end

  describe '.configure' do
    it 'yields the configuration object' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(AhoyCaptain::Configuration)
    end

    it 'allows setting configuration options' do
      described_class.configure do |config|
        config.theme = 'light'
        config.realtime_interval = 60.seconds
      end

      expect(described_class.config.theme).to eq('light')
      expect(described_class.config.realtime_interval).to eq(60.seconds)
    end

    it 'allows configuring cache settings' do
      described_class.configure do |config|
        config.cache[:enabled] = true
        config.cache[:ttl] = 5.minutes
      end

      expect(described_class.config.cache[:enabled]).to be(true)
      expect(described_class.config.cache[:ttl]).to eq(5.minutes)
    end

    it 'allows configuring model settings' do
      described_class.configure do |config|
        config.models[:event] = '::CustomEvent'
        config.models[:visit] = '::CustomVisit'
      end

      expect(described_class.config.models[:event]).to eq('::CustomEvent')
      expect(described_class.config.models[:visit]).to eq('::CustomVisit')
    end
  end

  describe '.config' do
    it 'returns a Configuration instance' do
      expect(described_class.config).to be_a(AhoyCaptain::Configuration)
    end

    it 'returns the same configuration instance on multiple calls' do
      first_call = described_class.config
      second_call = described_class.config

      expect(first_call).to be(second_call)
    end

    it 'creates a new configuration if none exists' do
      expect(described_class.configuration).to be_nil

      config = described_class.config

      expect(config).to be_a(AhoyCaptain::Configuration)
      expect(described_class.configuration).to be(config)
    end
  end

  describe '.cache' do
    context 'when cache is disabled' do
      before do
        described_class.configure do |config|
          config.cache[:enabled] = false
        end
      end

      it 'returns a NullStore' do
        expect(described_class.cache).to be_a(ActiveSupport::Cache::NullStore)
      end

      it 'returns the same cache instance on multiple calls' do
        first_call = described_class.cache
        second_call = described_class.cache

        expect(first_call).to be(second_call)
      end
    end

    context 'when cache is enabled' do
      let(:custom_store) { ActiveSupport::Cache::MemoryStore.new }

      before do
        described_class.configure do |config|
          config.cache[:enabled] = true
          config.cache[:store] = custom_store
        end
      end

      it 'returns the configured cache store' do
        expect(described_class.cache).to be(custom_store)
      end

      it 'returns the same cache instance on multiple calls' do
        first_call = described_class.cache
        second_call = described_class.cache

        expect(first_call).to be(second_call)
      end
    end

    context 'when cache is enabled with default store' do
      before do
        described_class.configure do |config|
          config.cache[:enabled] = true
        end
      end

      it 'returns Rails.cache as the default store' do
        expect(described_class.cache).to eq(Rails.cache)
      end
    end
  end

  describe '.event' do
    it 'returns the event model class' do
      expect(described_class.event).to eq(Ahoy::Event)
    end

    it 'memoizes the event class' do
      first_call = described_class.event
      second_call = described_class.event

      expect(first_call).to be(second_call)
    end

    it 'constantizes the configured model string' do
      expect(described_class.config.models[:event]).to eq('::Ahoy::Event')
      expect(described_class.event).to eq(Ahoy::Event)
    end
  end

  describe '.visit' do
    it 'returns the visit model class' do
      expect(described_class.visit).to eq(Ahoy::Visit)
    end

    it 'memoizes the visit class' do
      first_call = described_class.visit
      second_call = described_class.visit

      expect(first_call).to be(second_call)
    end

    it 'constantizes the configured model string' do
      expect(described_class.config.models[:visit]).to eq('::Ahoy::Visit')
      expect(described_class.visit).to eq(Ahoy::Visit)
    end
  end

  describe '.none' do
    it 'returns an OpenStruct placeholder' do
      expect(described_class.none).to be_a(OpenStruct)
    end

    it 'has text attribute set to "(none)"' do
      expect(described_class.none.text).to eq('(none)')
    end

    it 'has value attribute set to "!none!"' do
      expect(described_class.none.value).to eq('!none!')
    end

    it 'memoizes the none placeholder' do
      first_call = described_class.none
      second_call = described_class.none

      expect(first_call).to be(second_call)
    end
  end

  describe '.configuration' do
    it 'is accessible as an attribute' do
      config = AhoyCaptain::Configuration.new
      described_class.configuration = config

      expect(described_class.configuration).to be(config)
    end

    it 'defaults to nil before config is called' do
      expect(described_class.configuration).to be_nil
    end
  end
end
