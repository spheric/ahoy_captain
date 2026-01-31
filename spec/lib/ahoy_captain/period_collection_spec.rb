# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AhoyCaptain::PeriodCollection do
  subject(:collection) { described_class.new }

  describe AhoyCaptain::PeriodCollection::Period do
    subject(:period) { described_class.new(param: :day, label: 'Day', range: range_proc) }

    let(:range_proc) { -> { [1.day.ago, Time.current] } }

    it 'stores param' do
      expect(period.param).to eq(:day)
    end

    it 'stores label' do
      expect(period.label).to eq('Day')
    end

    it 'stores range proc' do
      expect(period.range).to eq(range_proc)
    end
  end

  describe '.load_default' do
    subject(:default_collection) { described_class.load_default }

    it 'returns a PeriodCollection instance' do
      expect(default_collection).to be_a(described_class)
    end

    it 'includes realtime period' do
      expect(default_collection.find(:realtime)).to be_present
    end

    it 'includes day period' do
      expect(default_collection.find(:day)).to be_present
    end

    it 'includes 7d period' do
      expect(default_collection.find(:'7d')).to be_present
    end

    it 'includes 30d period' do
      expect(default_collection.find(:'30d')).to be_present
    end

    it 'includes mtd period' do
      expect(default_collection.find(:mtd)).to be_present
    end

    it 'includes lastmonth period' do
      expect(default_collection.find(:lastmonth)).to be_present
    end

    it 'includes ytd period' do
      expect(default_collection.find(:ytd)).to be_present
    end

    it 'includes 12mo period' do
      expect(default_collection.find(:'12mo')).to be_present
    end

    it 'includes all period' do
      expect(default_collection.find(:all)).to be_present
    end

    it 'sets 30d as default' do
      expect(default_collection.default).to eq(:'30d')
    end
  end

  describe '#add' do
    let(:range_proc) { -> { [1.week.ago, Time.current] } }

    it 'adds a period to the collection' do
      collection.add(:weekly, 'Weekly', range_proc)

      expect(collection.find(:weekly)).to be_present
    end

    it 'converts param to symbol' do
      collection.add('weekly', 'Weekly', range_proc)

      expect(collection.find(:weekly)).to be_present
    end

    context 'when range is not callable' do
      it 'raises ArgumentError' do
        expect { collection.add(:test, 'Test', 'not a proc') }
          .to raise_error(ArgumentError, /range must be a proc/)
      end
    end

    context 'when range does not return Array or Range' do
      it 'raises ArgumentError' do
        expect { collection.add(:test, 'Test', -> { 'invalid' }) }
          .to raise_error(ArgumentError, /range.call must return a range or an array/)
      end
    end

    context 'when range returns an Array' do
      it 'accepts the period' do
        collection.add(:test, 'Test', -> { [1.day.ago, Time.current] })

        expect(collection.find(:test)).to be_present
      end
    end

    context 'when range returns a Range' do
      it 'accepts the period' do
        collection.add(:test, 'Test', -> { 1.day.ago..Time.current })

        expect(collection.find(:test)).to be_present
      end
    end
  end

  describe '#delete' do
    before do
      collection.add(:test, 'Test', -> { [1.day.ago, Time.current] })
    end

    it 'removes the period from collection' do
      collection.delete(:test)

      expect(collection.find(:test)).to be_nil
    end

    it 'accepts string param' do
      collection.delete('test')

      expect(collection.find(:test)).to be_nil
    end
  end

  describe '#reset' do
    before do
      collection.add(:test, 'Test', -> { [1.day.ago, Time.current] })
      collection.default = :test
    end

    it 'clears all periods' do
      collection.reset

      expect(collection.all).to be_empty
    end

    it 'clears default' do
      collection.reset

      expect(collection.default).to be_nil
    end
  end

  describe '#each' do
    before do
      collection.add(:a, 'A', -> { [1.day.ago, Time.current] })
      collection.add(:b, 'B', -> { [2.days.ago, Time.current] })
    end

    it 'yields each period' do
      params = []
      collection.each { |param, _period| params << param }

      expect(params).to contain_exactly(:a, :b)
    end
  end

  describe '#find' do
    before do
      collection.add(:test, 'Test', -> { [1.day.ago, Time.current] })
    end

    it 'returns period by symbol' do
      expect(collection.find(:test)).to be_a(AhoyCaptain::PeriodCollection::Period)
    end

    it 'returns period by string' do
      expect(collection.find('test')).to be_a(AhoyCaptain::PeriodCollection::Period)
    end

    it 'returns nil for unknown period' do
      expect(collection.find(:unknown)).to be_nil
    end
  end

  describe '#all' do
    before do
      collection.add(:test, 'Test', -> { [1.day.ago, Time.current] })
    end

    it 'returns hash of all periods' do
      expect(collection.all).to be_a(Hash)
      expect(collection.all.keys).to contain_exactly(:test)
    end
  end

  describe '#default=' do
    it 'sets default period' do
      collection.default = :test

      expect(collection.default).to eq(:test)
    end

    it 'converts string to symbol' do
      collection.default = 'test'

      expect(collection.default).to eq(:test)
    end
  end

  describe '#max=' do
    it 'sets max value' do
      collection.max = 180.days

      expect(collection.max).to eq(180.days)
    end
  end

  describe '#for' do
    let(:time_now) { Time.current }

    before do
      collection.add(:day, 'Day', -> { [1.day.ago, Time.current] })
      collection.add(:week, 'Week', -> { [1.week.ago, Time.current] })
      collection.default = :day
    end

    it 'returns range for specified period' do
      result = collection.for(:week)

      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
    end

    it 'returns default range when value is nil' do
      result = collection.for(nil)

      expect(result).to be_an(Array)
    end

    it 'returns default range when period not found' do
      result = collection.for(:unknown)

      expect(result).to be_an(Array)
    end

    it 'accepts string param' do
      result = collection.for('week')

      expect(result).to be_an(Array)
    end

    context 'when no periods configured' do
      let(:empty_collection) { described_class.new }

      it 'returns nil' do
        expect(empty_collection.for(:anything)).to be_nil
      end
    end
  end
end
