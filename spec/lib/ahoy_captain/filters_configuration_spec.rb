# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::FiltersConfiguration do
  subject(:config) { described_class.new }

  describe AhoyCaptain::FilterConfiguration::Filter do
    subject(:filter) do
      described_class.new(
        label: 'Country',
        column: :country,
        url: :filters_locations_countries_path,
        predicates: [:in, :not_in],
        multiple: true,
        position: 1
      )
    end

    it 'stores column' do
      expect(filter.column).to eq(:country)
    end

    it 'stores label' do
      expect(filter.label).to eq('Country')
    end

    it 'stores url' do
      expect(filter.url).to eq(:filters_locations_countries_path)
    end

    it 'stores predicates' do
      expect(filter.predicates).to eq([:in, :not_in])
    end

    it 'stores multiple' do
      expect(filter.multiple).to be(true)
    end

    it 'stores position' do
      expect(filter.position).to eq(1)
    end

    context 'with default values' do
      subject(:filter_with_defaults) do
        described_class.new(
          label: 'Test',
          column: :test,
          url: :test_path
        )
      end

      it 'defaults predicates to [:in, :not_in]' do
        expect(filter_with_defaults.predicates).to eq([:in, :not_in])
      end

      it 'defaults multiple to true' do
        expect(filter_with_defaults.multiple).to be(true)
      end

      it 'defaults position to nil' do
        expect(filter_with_defaults.position).to be_nil
      end
    end
  end

  describe AhoyCaptain::FilterConfiguration::FilterCollection do
    subject(:collection) { described_class.new('Geography') }

    describe '#initialize' do
      it 'sets label' do
        expect(collection.modal_name).to eq('geographyModal')
      end
    end

    describe '#filter' do
      it 'adds a filter to the collection' do
        collection.filter(label: 'Country', column: :country, url: :countries_path)

        expect(collection.find(:country)).to be_present
      end

      it 'replaces existing filter with same column' do
        collection.filter(label: 'Country', column: :country, url: :old_path)
        collection.filter(label: 'Country Updated', column: :country, url: :new_path)

        expect(collection.filters.count).to eq(1)
        expect(collection.find(:country).url).to eq(:new_path)
      end

      it 'assigns position automatically if not provided' do
        collection.filter(label: 'First', column: :first, url: :first_path)
        collection.filter(label: 'Second', column: :second, url: :second_path)

        expect(collection.find(:first).position).to eq(0)
        expect(collection.find(:second).position).to eq(1)
      end

      it 'respects explicit position' do
        collection.filter(label: 'First', column: :first, url: :first_path, position: 10)
        collection.filter(label: 'Second', column: :second, url: :second_path, position: 5)

        expect(collection.filters.first.column).to eq(:second)
        expect(collection.filters.last.column).to eq(:first)
      end

      it 'supports custom predicates' do
        collection.filter(label: 'UTM', column: :utm, url: :utm_path, predicates: [:in, :not_in, :cont])

        expect(collection.find(:utm).predicates).to eq([:in, :not_in, :cont])
      end

      it 'supports multiple option' do
        collection.filter(label: 'Single', column: :single, url: :single_path, multiple: false)

        expect(collection.find(:single).multiple).to be(false)
      end
    end

    describe '#each' do
      before do
        collection.filter(label: 'A', column: :a, url: :a_path)
        collection.filter(label: 'B', column: :b, url: :b_path)
      end

      it 'yields each filter' do
        columns = []
        collection.each { |filter| columns << filter.column }

        expect(columns).to contain_exactly(:a, :b)
      end
    end

    describe '#modal_name' do
      it 'returns parameterized underscored label with Modal suffix' do
        expect(collection.modal_name).to eq('geographyModal')
      end

      context 'with multi-word label' do
        subject(:collection) { described_class.new('Screen size') }

        it 'handles spaces correctly' do
          expect(collection.modal_name).to eq('screen_sizeModal')
        end
      end

      context 'with UTM Tags label' do
        subject(:collection) { described_class.new('UTM Tags') }

        it 'handles UTM Tags correctly' do
          expect(collection.modal_name).to eq('utm_tagsModal')
        end
      end
    end

    describe '#find' do
      before do
        collection.filter(label: 'Country', column: :country, url: :country_path)
      end

      it 'finds filter by symbol' do
        expect(collection.find(:country)).to be_a(AhoyCaptain::FilterConfiguration::Filter)
      end

      it 'finds filter by string' do
        expect(collection.find('country')).to be_a(AhoyCaptain::FilterConfiguration::Filter)
      end

      it 'returns nil for unknown column' do
        expect(collection.find(:unknown)).to be_nil
      end
    end

    describe '#delete' do
      before do
        collection.filter(label: 'Country', column: :country, url: :country_path)
        collection.filter(label: 'Region', column: :region, url: :region_path)
      end

      it 'removes filter by column name' do
        collection.delete(:country)

        expect(collection.find(:country)).to be_nil
      end

      it 'keeps other filters' do
        collection.delete(:country)

        expect(collection.find(:region)).to be_present
      end
    end

    describe '#filters' do
      before do
        collection.filter(label: 'A', column: :a, url: :a_path)
      end

      it 'returns array of filters' do
        expect(collection.filters).to be_an(Array)
        expect(collection.filters.first).to be_a(AhoyCaptain::FilterConfiguration::Filter)
      end
    end

    describe '#[]' do
      before do
        collection.filter(label: 'Country', column: :country, url: :country_path)
      end

      it 'is an alias for find' do
        expect(collection[:country]).to eq(collection.find(:country))
      end
    end

    describe '#include?' do
      before do
        collection.filter(label: 'Country', column: :country, url: :country_path)
      end

      it 'returns true when filter exists' do
        expect(collection.include?(:country)).to be(true)
      end

      it 'returns false when filter does not exist' do
        expect(collection.include?(:unknown)).to be(false)
      end
    end
  end

  describe '.load_default' do
    subject(:default_config) { described_class.load_default }

    it 'returns a FiltersConfiguration instance' do
      expect(default_config).to be_a(described_class)
    end

    it 'includes Page filter group' do
      expect(default_config['Page']).to be_present
    end

    it 'includes Geography filter group' do
      expect(default_config['Geography']).to be_present
    end

    it 'includes Source filter group' do
      expect(default_config['Source']).to be_present
    end

    it 'includes Screen size filter group' do
      expect(default_config['Screen size']).to be_present
    end

    it 'includes Operating System filter group' do
      expect(default_config['Operating System']).to be_present
    end

    it 'includes UTM Tags filter group' do
      expect(default_config['UTM Tags']).to be_present
    end

    it 'includes Goal filter group' do
      expect(default_config['Goal']).to be_present
    end

    describe 'Page filters' do
      let(:page_filters) { default_config['Page'] }

      it 'includes route filter' do
        expect(page_filters.find(:route)).to be_present
      end

      it 'includes entry_page filter' do
        expect(page_filters.find(:entry_page)).to be_present
      end

      it 'includes exit_page filter' do
        expect(page_filters.find(:exit_page)).to be_present
      end
    end

    describe 'Geography filters' do
      let(:geo_filters) { default_config['Geography'] }

      it 'includes country filter' do
        expect(geo_filters.find(:country)).to be_present
      end

      it 'includes region filter' do
        expect(geo_filters.find(:region)).to be_present
      end

      it 'includes city filter' do
        expect(geo_filters.find(:city)).to be_present
      end
    end

    describe 'UTM Tags filters' do
      let(:utm_filters) { default_config['UTM Tags'] }

      it 'includes utm_medium filter with cont predicate' do
        filter = utm_filters.find(:utm_medium)

        expect(filter.predicates).to include(:cont)
      end

      it 'includes utm_source filter' do
        expect(utm_filters.find(:utm_source)).to be_present
      end

      it 'includes utm_campaign filter' do
        expect(utm_filters.find(:utm_campaign)).to be_present
      end

      it 'includes utm_term filter' do
        expect(utm_filters.find(:utm_term)).to be_present
      end

      it 'includes utm_content filter' do
        expect(utm_filters.find(:utm_content)).to be_present
      end
    end

    describe 'Goal filter' do
      let(:goal_filters) { default_config['Goal'] }

      it 'has only :in predicate' do
        filter = goal_filters.find(:goal)

        expect(filter.predicates).to eq([:in])
      end
    end
  end

  describe '#register' do
    it 'adds a filter group to the registry' do
      config.register('Custom') do
        filter column: :custom_field, label: 'Custom Field', url: :custom_path
      end

      expect(config['Custom']).to be_present
    end

    it 'creates a FilterCollection for the group' do
      config.register('Custom') do
        filter column: :custom_field, label: 'Custom Field', url: :custom_path
      end

      expect(config['Custom']).to be_a(AhoyCaptain::FilterConfiguration::FilterCollection)
    end

    it 'allows adding multiple filters in a group' do
      config.register('Custom') do
        filter column: :field1, label: 'Field 1', url: :field1_path
        filter column: :field2, label: 'Field 2', url: :field2_path
      end

      expect(config['Custom'].find(:field1)).to be_present
      expect(config['Custom'].find(:field2)).to be_present
    end
  end

  describe '#[]' do
    before do
      config.register('Test') do
        filter column: :test, label: 'Test', url: :test_path
      end
    end

    it 'returns filter group by name' do
      expect(config['Test']).to be_a(AhoyCaptain::FilterConfiguration::FilterCollection)
    end

    it 'returns nil for unknown group' do
      expect(config['Unknown']).to be_nil
    end
  end

  describe '#delete' do
    before do
      config.register('Test') do
        filter column: :test, label: 'Test', url: :test_path
      end
    end

    it 'removes filter group by name' do
      config.delete('Test')

      expect(config['Test']).to be_nil
    end
  end

  describe '#reset' do
    before do
      config.register('Test') do
        filter column: :test, label: 'Test', url: :test_path
      end
    end

    it 'clears all filter groups' do
      config.reset

      expect(config['Test']).to be_nil
    end
  end

  describe '#each' do
    before do
      config.register('A') do
        filter column: :a, label: 'A', url: :a_path
      end
      config.register('B') do
        filter column: :b, label: 'B', url: :b_path
      end
    end

    it 'yields each filter group' do
      names = []
      config.each { |name, _collection| names << name }

      expect(names).to contain_exactly('A', 'B')
    end
  end

  describe '#detect' do
    before do
      config.register('Page') do
        filter column: :route, label: 'Route', url: :route_path
      end
      config.register('Geography') do
        filter column: :country, label: 'Country', url: :country_path
      end
    end

    it 'finds first matching group' do
      result = config.detect { |name, _collection| name == 'Page' }

      expect(result.first).to eq('Page')
    end

    it 'returns nil when no match' do
      result = config.detect { |name, _collection| name == 'Unknown' }

      expect(result).to be_nil
    end
  end
end
