# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Configuration do
  subject(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default theme to dark' do
      expect(config.theme).to eq('dark')
    end

    it 'sets default realtime_interval to 30 seconds' do
      expect(config.realtime_interval).to eq(30.seconds)
    end

    it 'sets empty disabled_widgets array' do
      expect(config.disabled_widgets).to eq([])
    end

    it 'initializes goals collection' do
      expect(config.goals).to be_a(AhoyCaptain::GoalCollection)
    end

    it 'initializes funnels collection' do
      expect(config.funnels).to be_a(AhoyCaptain::FunnelCollection)
    end

    it 'initializes ranges with defaults' do
      expect(config.ranges).to be_a(AhoyCaptain::PeriodCollection)
    end

    describe 'cache defaults' do
      it 'sets enabled to false' do
        expect(config.cache[:enabled]).to be(false)
      end

      it 'sets store to Rails.cache' do
        expect(config.cache[:store]).to eq(Rails.cache)
      end

      it 'sets ttl to 1 minute' do
        expect(config.cache[:ttl]).to eq(1.minute)
      end
    end

    describe 'models defaults' do
      it 'sets event model to Ahoy::Event' do
        expect(config.models[:event]).to eq('::Ahoy::Event')
      end

      it 'sets visit model to Ahoy::Visit' do
        expect(config.models[:visit]).to eq('::Ahoy::Visit')
      end
    end

    describe 'event defaults' do
      it 'sets view_name to $view' do
        expect(config.event[:view_name]).to eq('$view')
      end

      it 'sets url_column for controller#action format' do
        expect(config.event[:url_column]).to include('controller')
        expect(config.event[:url_column]).to include('action')
      end

      it 'sets url_exists check for JSONB properties' do
        expect(config.event[:url_exists]).to include('JSONB_EXISTS')
      end
    end

    describe 'predicate_labels' do
      it 'includes eq label' do
        expect(config.predicate_labels[:eq]).to eq('equals')
      end

      it 'includes not_eq label' do
        expect(config.predicate_labels[:not_eq]).to eq('not equals')
      end

      it 'includes cont label' do
        expect(config.predicate_labels[:cont]).to eq('contains')
      end

      it 'includes in label' do
        expect(config.predicate_labels[:in]).to eq('in')
      end

      it 'includes not_in label' do
        expect(config.predicate_labels[:not_in]).to eq('not in')
      end
    end
  end

  describe '#goal' do
    it 'registers a new goal' do
      config.goal(:test_goal) do
        label 'Test Goal'
        name 'test_event'
      end

      expect(config.goals[:test_goal]).to be_present
    end

    it 'sets goal id' do
      config.goal(:my_goal) do
        label 'My Goal'
        name 'my_event'
      end

      expect(config.goals[:my_goal].id).to eq(:my_goal)
    end
  end

  describe '#funnel' do
    it 'registers a new funnel' do
      config.goal(:step1) { label 'Step 1'; name 'step1' }
      config.goal(:step2) { label 'Step 2'; name 'step2' }

      config.funnel(:test_funnel) do
        label 'Test Funnel'
        goal :step1
        goal :step2
      end

      expect(config.funnels[:test_funnel]).to be_present
    end

    it 'sets funnel id' do
      config.funnel(:my_funnel) do
        label 'My Funnel'
      end

      expect(config.funnels[:my_funnel].id).to eq(:my_funnel)
    end
  end

  describe 'attribute accessors' do
    it 'allows setting view_name' do
      config.view_name = 'page_view'

      expect(config.view_name).to eq('page_view')
    end

    it 'allows setting theme' do
      config.theme = 'light'

      expect(config.theme).to eq('light')
    end

    it 'allows setting realtime_interval' do
      config.realtime_interval = 60.seconds

      expect(config.realtime_interval).to eq(60.seconds)
    end

    it 'allows setting disabled_widgets' do
      config.disabled_widgets = [:sources, :campaigns]

      expect(config.disabled_widgets).to eq([:sources, :campaigns])
    end
  end
end
