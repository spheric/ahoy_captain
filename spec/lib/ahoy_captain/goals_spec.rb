# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Goal do
  subject(:goal) { described_class.new }

  describe '#initialize' do
    it 'sets id to nil' do
      expect(goal.id).to be_nil
    end

    it 'sets title to nil' do
      expect(goal.title).to be_nil
    end

    it 'sets event_query to nil' do
      expect(goal.event_query).to be_nil
    end
  end

  describe '#id=' do
    it 'allows setting the id' do
      goal.id = :test_goal

      expect(goal.id).to eq(:test_goal)
    end
  end

  describe '#label' do
    it 'sets the title' do
      goal.label('My Goal')

      expect(goal.title).to eq('My Goal')
    end
  end

  describe '#name' do
    it 'sets the event_query as a lambda' do
      goal.name('test_event')

      expect(goal.event_query).to be_a(Proc)
    end

    it 'creates a query that filters by event name' do
      goal.name('purchase')
      query = goal.event_query.call

      expect(query.to_sql).to include("\"name\" = 'purchase'")
    end
  end

  describe '#event' do
    # Note: The implementation uses ActiveSupport::Deprecation.warn which is
    # a private method in Rails 7.1+. This raises a NoMethodError.
    # These tests document the current behavior.

    it 'raises NoMethodError due to deprecated ActiveSupport::Deprecation.warn usage' do
      expect { goal.event('test_event') }.to raise_error(NoMethodError, /private method 'warn'/)
    end
  end

  describe '#query' do
    it 'sets the event_query to the provided block' do
      custom_query = -> { AhoyCaptain.event.where(name: 'custom') }
      goal.query(&custom_query)

      expect(goal.event_query).to eq(custom_query)
    end

    it 'allows custom query logic' do
      goal.query { AhoyCaptain.event.where("properties->>'value' > ?", 100) }

      expect(goal.event_query).to be_a(Proc)
    end
  end
end

RSpec.describe AhoyCaptain::GoalCollection do
  subject(:collection) { described_class.new }

  describe '#initialize' do
    it 'creates an empty collection' do
      expect(collection.count).to eq(0)
    end
  end

  describe '#register' do
    it 'adds a goal to the collection' do
      goal = AhoyCaptain::Goal.new
      goal.id = :test_goal

      collection.register(goal)

      expect(collection.count).to eq(1)
    end

    it 'stores goal by its id' do
      goal = AhoyCaptain::Goal.new
      goal.id = :my_goal
      goal.label('My Goal')

      collection.register(goal)

      expect(collection[:my_goal]).to eq(goal)
    end

    it 'overwrites existing goal with same id' do
      goal1 = AhoyCaptain::Goal.new
      goal1.id = :same_id
      goal1.label('First Goal')

      goal2 = AhoyCaptain::Goal.new
      goal2.id = :same_id
      goal2.label('Second Goal')

      collection.register(goal1)
      collection.register(goal2)

      expect(collection.count).to eq(1)
      expect(collection[:same_id].title).to eq('Second Goal')
    end
  end

  describe '#each' do
    it 'iterates over all goals' do
      goal1 = AhoyCaptain::Goal.new
      goal1.id = :goal1
      goal2 = AhoyCaptain::Goal.new
      goal2.id = :goal2

      collection.register(goal1)
      collection.register(goal2)

      goals = []
      collection.each { |g| goals << g }

      expect(goals).to contain_exactly(goal1, goal2)
    end

    it 'returns an enumerator when no block given' do
      expect(collection.each).to be_an(Enumerator)
    end
  end

  describe '#[]' do
    it 'retrieves goal by symbol key' do
      goal = AhoyCaptain::Goal.new
      goal.id = :test_goal

      collection.register(goal)

      expect(collection[:test_goal]).to eq(goal)
    end

    it 'retrieves goal by string key (indifferent access)' do
      goal = AhoyCaptain::Goal.new
      goal.id = :test_goal

      collection.register(goal)

      expect(collection['test_goal']).to eq(goal)
    end

    it 'returns nil for non-existent key' do
      expect(collection[:nonexistent]).to be_nil
    end
  end

  describe 'Enumerable' do
    it 'includes Enumerable module' do
      expect(described_class.ancestors).to include(Enumerable)
    end

    it 'supports map' do
      goal1 = AhoyCaptain::Goal.new
      goal1.id = :goal1
      goal1.label('Goal One')

      goal2 = AhoyCaptain::Goal.new
      goal2.id = :goal2
      goal2.label('Goal Two')

      collection.register(goal1)
      collection.register(goal2)

      titles = collection.map(&:title)

      expect(titles).to contain_exactly('Goal One', 'Goal Two')
    end

    it 'supports select' do
      goal1 = AhoyCaptain::Goal.new
      goal1.id = :goal1
      goal1.label('First')

      goal2 = AhoyCaptain::Goal.new
      goal2.id = :goal2
      goal2.label('Second Goal')

      collection.register(goal1)
      collection.register(goal2)

      long_titles = collection.select { |g| g.title.length > 5 }

      expect(long_titles.map(&:id)).to eq([:goal2])
    end

    it 'supports find' do
      goal1 = AhoyCaptain::Goal.new
      goal1.id = :goal1

      goal2 = AhoyCaptain::Goal.new
      goal2.id = :goal2

      collection.register(goal1)
      collection.register(goal2)

      found = collection.find { |g| g.id == :goal2 }

      expect(found).to eq(goal2)
    end
  end
end
