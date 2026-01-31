# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Funnel do
  subject(:funnel) { described_class.new }

  describe '#initialize' do
    it 'sets id to nil' do
      expect(funnel.id).to be_nil
    end

    it 'sets goals to empty array' do
      expect(funnel.goals).to eq([])
    end

    it 'sets label to nil' do
      expect(funnel.title).to be_nil
    end
  end

  describe '#id=' do
    it 'sets the id' do
      funnel.id = :checkout_funnel

      expect(funnel.id).to eq(:checkout_funnel)
    end
  end

  describe '#label' do
    it 'sets the label' do
      funnel.label('Checkout Funnel')

      expect(funnel.title).to eq('Checkout Funnel')
    end
  end

  describe '#title' do
    it 'returns the label value' do
      funnel.label('My Funnel')

      expect(funnel.title).to eq('My Funnel')
    end

    it 'returns nil when label not set' do
      expect(funnel.title).to be_nil
    end
  end

  describe '#goal' do
    let(:config) { AhoyCaptain::Configuration.new }

    before do
      allow(AhoyCaptain).to receive(:config).and_return(config)

      config.goal(:step1) do
        label 'Step 1'
        name 'step1_event'
      end

      config.goal(:step2) do
        label 'Step 2'
        name 'step2_event'
      end
    end

    it 'adds a goal to the funnel goals array' do
      funnel.goal(:step1)

      expect(funnel.goals.length).to eq(1)
    end

    it 'adds the correct goal from config' do
      funnel.goal(:step1)

      expect(funnel.goals.first).to eq(config.goals[:step1])
    end

    it 'adds multiple goals in order' do
      funnel.goal(:step1)
      funnel.goal(:step2)

      expect(funnel.goals.length).to eq(2)
      expect(funnel.goals.first).to eq(config.goals[:step1])
      expect(funnel.goals.last).to eq(config.goals[:step2])
    end

    it 'returns nil when goal does not exist in config' do
      funnel.goal(:nonexistent)

      expect(funnel.goals).to include(nil)
    end
  end

  describe '#goals' do
    it 'returns the goals array' do
      expect(funnel.goals).to be_an(Array)
    end

    it 'is readable' do
      expect { funnel.goals }.not_to raise_error
    end
  end
end

RSpec.describe AhoyCaptain::FunnelCollection do
  subject(:collection) { described_class.new }

  describe '#initialize' do
    it 'creates an empty collection' do
      expect(collection.to_a).to be_empty
    end
  end

  describe '#register' do
    let(:funnel) do
      AhoyCaptain::Funnel.new.tap do |f|
        f.id = :checkout
        f.label('Checkout')
      end
    end

    it 'adds a funnel to the collection' do
      collection.register(funnel)

      expect(collection[:checkout]).to eq(funnel)
    end

    it 'uses the funnel id as the key' do
      funnel.id = :my_funnel
      collection.register(funnel)

      expect(collection[:my_funnel]).to eq(funnel)
    end

    it 'overwrites existing funnel with same id' do
      first_funnel = AhoyCaptain::Funnel.new.tap { |f| f.id = :checkout }
      second_funnel = AhoyCaptain::Funnel.new.tap { |f| f.id = :checkout }

      collection.register(first_funnel)
      collection.register(second_funnel)

      expect(collection[:checkout]).to eq(second_funnel)
    end
  end

  describe '#[]' do
    let(:funnel) do
      AhoyCaptain::Funnel.new.tap do |f|
        f.id = :checkout
        f.label('Checkout')
      end
    end

    before { collection.register(funnel) }

    it 'retrieves funnel by symbol key' do
      expect(collection[:checkout]).to eq(funnel)
    end

    it 'retrieves funnel by string key' do
      expect(collection['checkout']).to eq(funnel)
    end

    it 'returns nil for nonexistent key' do
      expect(collection[:nonexistent]).to be_nil
    end
  end

  describe '#each' do
    let(:funnel1) do
      AhoyCaptain::Funnel.new.tap do |f|
        f.id = :funnel1
        f.label('Funnel 1')
      end
    end

    let(:funnel2) do
      AhoyCaptain::Funnel.new.tap do |f|
        f.id = :funnel2
        f.label('Funnel 2')
      end
    end

    before do
      collection.register(funnel1)
      collection.register(funnel2)
    end

    it 'yields each funnel with its key' do
      keys = []
      funnels = []

      collection.each do |key, funnel|
        keys << key
        funnels << funnel
      end

      expect(keys).to contain_exactly(:funnel1, :funnel2)
      expect(funnels).to contain_exactly(funnel1, funnel2)
    end

    it 'includes Enumerable methods' do
      expect(collection).to respond_to(:map)
      expect(collection).to respond_to(:select)
      expect(collection).to respond_to(:to_a)
    end
  end

  describe 'Enumerable behavior' do
    let(:funnel) do
      AhoyCaptain::Funnel.new.tap do |f|
        f.id = :test
        f.label('Test')
      end
    end

    before { collection.register(funnel) }

    it 'responds to count' do
      expect(collection.count).to eq(1)
    end

    it 'responds to map' do
      ids = collection.map { |key, _funnel| key }

      expect(ids).to eq([:test])
    end

    it 'responds to select' do
      selected = collection.select { |key, _funnel| key == :test }

      expect(selected.length).to eq(1)
    end
  end
end
