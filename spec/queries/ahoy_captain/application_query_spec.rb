# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::ApplicationQuery do
  # Create a concrete implementation for testing the base class
  let(:test_query_class) do
    Class.new(described_class) do
      def build
        AhoyCaptain.event.all
      end
    end
  end

  let(:base_params) do
    {
      start_date: 30.days.ago,
      end_date: Time.current,
      period: '30d',
      controller: 'ahoy_captain/stats'
    }
  end

  describe '.strict' do
    it 'defaults to true' do
      expect(described_class.strict).to be true
    end

    it 'is a class attribute' do
      expect(described_class).to respond_to(:strict)
      expect(described_class).to respond_to(:strict=)
    end
  end

  describe '.call' do
    it 'creates an instance and calls the private call method' do
      result = test_query_class.call(base_params)

      expect(result).to be_a(test_query_class)
    end

    it 'accepts an optional query parameter' do
      initial_query = AhoyCaptain.event.where(name: '$view')
      result = test_query_class.call(base_params, initial_query)

      expect(result).to be_a(test_query_class)
    end
  end

  describe '#initialize' do
    subject(:query) { test_query_class.new(base_params, nil) }

    it 'stores the params' do
      expect(query.params).to eq(base_params)
    end

    it 'makes params accessible via attr_reader' do
      expect(query).to respond_to(:params)
    end
  end

  describe '#inspect' do
    subject(:query) { test_query_class.new(base_params, nil) }

    it 'returns a formatted string with the class name' do
      expect(query.inspect).to match(/<.*>/)
    end
  end

  describe 'delegate_missing_to' do
    it 'delegates missing methods to the query' do
      result = test_query_class.call(base_params)

      expect(result).to respond_to(:to_sql)
      expect(result).to respond_to(:where)
    end
  end

  describe 'strict mode' do
    context 'when strict is enabled and build returns self (same class)' do
      let(:self_returning_query_class) do
        Class.new(described_class) do
          def build
            self
          end
        end
      end

      it 'raises an ArgumentError' do
        expect {
          self_returning_query_class.call(base_params)
        }.to raise_error(ArgumentError, /has strict enabled, and should return a relation/)
      end
    end

    context 'when strict is disabled' do
      let(:non_strict_query_class) do
        Class.new(described_class) do
          self.strict = false

          def build
            "not a relation"
          end
        end
      end

      it 'does not raise an error' do
        expect {
          non_strict_query_class.call(base_params)
        }.not_to raise_error
      end
    end

    context 'when build returns an ActiveRecord::Relation' do
      it 'does not raise an error' do
        expect {
          test_query_class.call(base_params)
        }.not_to raise_error
      end
    end

    context 'when build returns a different class (not self)' do
      let(:different_class_query) do
        Class.new(described_class) do
          def build
            "a string"
          end
        end
      end

      it 'does not raise an error because class differs from self' do
        # The strict check allows returning different classes
        # This supports returning wrapper objects or other query classes
        expect {
          different_class_query.call(base_params)
        }.not_to raise_error
      end
    end
  end

  describe '#build' do
    it 'raises NotImplementedError when not overridden' do
      query = described_class.new(base_params, nil)

      expect { query.send(:build) }.to raise_error(NotImplementedError)
    end
  end

  describe 'ransack integration' do
    describe '#ransack_params_for' do
      let(:query_with_ransack) do
        Class.new(described_class) do
          def build
            AhoyCaptain.event.all
          end

          # Expose the method for testing
          public :ransack_params_for
        end
      end

      context 'with event type' do
        it 'returns ransackable params for events' do
          params = base_params.merge(q: { 'name_eq' => '$view' })
          query = query_with_ransack.new(params, nil)
          result = query.ransack_params_for(:event)

          expect(result).to be_a(Hash)
          expect(result).to include('name_eq' => '$view')
        end

        it 'prefixes visit attributes with visit_' do
          params = base_params.merge(q: { 'browser_eq' => 'Chrome' })
          query = query_with_ransack.new(params, nil)
          result = query.ransack_params_for(:event)

          expect(result).to include('visit_browser_eq' => 'Chrome')
        end

        it 'adds time range params' do
          query = query_with_ransack.new(base_params, nil)
          result = query.ransack_params_for(:event)

          expect(result.keys).to include('time_gt', 'time_lt')
        end
      end

      context 'with visit type' do
        it 'returns ransackable params for visits' do
          params = base_params.merge(q: { 'browser_eq' => 'Chrome' })
          query = query_with_ransack.new(params, nil)
          result = query.ransack_params_for(:visit)

          expect(result).to be_a(Hash)
          expect(result).to include('browser_eq' => 'Chrome')
        end

        it 'prefixes event attributes with events_' do
          params = base_params.merge(q: { 'name_eq' => '$view' })
          query = query_with_ransack.new(params, nil)
          result = query.ransack_params_for(:visit)

          expect(result).to include('events_name_eq' => '$view')
        end

        it 'adds started_at range params' do
          query = query_with_ransack.new(base_params, nil)
          result = query.ransack_params_for(:visit)

          expect(result.keys).to include('started_at_gt', 'started_at_lt')
        end
      end

      context 'with none value handling' do
        it 'transforms none value to null predicate' do
          params = base_params.merge(q: { 'utm_source_eq' => AhoyCaptain.none.value })
          query = query_with_ransack.new(params, nil)
          result = query.ransack_params_for(:visit)

          expect(result).to include('utm_source_null' => '1')
          expect(result).not_to have_key('utm_source_eq')
        end

        it 'transforms none value in array to null predicate' do
          params = base_params.merge(q: { 'utm_source_eq' => [AhoyCaptain.none.value] })
          query = query_with_ransack.new(params, nil)
          result = query.ransack_params_for(:visit)

          expect(result).to include('utm_source_null' => '1')
        end

        it 'transforms not predicates with none value to not_null' do
          params = base_params.merge(q: { 'utm_source_not_eq' => AhoyCaptain.none.value })
          query = query_with_ransack.new(params, nil)
          result = query.ransack_params_for(:visit)

          expect(result).to include('utm_source_not_null' => '1')
        end
      end

      context 'with no q params' do
        it 'returns empty ransackable params plus time ranges' do
          query = query_with_ransack.new(base_params, nil)
          result = query.ransack_params_for(:event)

          expect(result.keys).to include('time_gt', 'time_lt')
        end
      end
    end

    describe '#ransackify' do
      let(:query_with_ransackify) do
        Class.new(described_class) do
          def build
            AhoyCaptain.event.all
          end

          public :ransackify
        end
      end

      it 'returns nil for nil input' do
        query = query_with_ransackify.new(base_params, nil)

        expect(query.ransackify(nil, :event)).to be_nil
      end

      it 'handles properties with predicates' do
        query = query_with_ransackify.new(base_params, nil)
        params = { 'properties.category_eq' => 'test' }
        result = query.ransackify(params, :event)

        expect(result).to have_key(:c)
        expect(result[:c]).to be_an(Array)
        expect(result[:c].first[:p]).to eq('eq')
      end

      it 'handles properties with events prefix for visit type' do
        query = query_with_ransackify.new(base_params, nil)
        params = { 'properties.category_eq' => 'test' }
        result = query.ransackify(params, :visit)

        expect(result[:c].first[:a]['0'][:name]).to eq('events_properties')
      end

      it 'preserves non-property params' do
        query = query_with_ransackify.new(base_params, nil)
        params = { 'name_eq' => '$view', 'time_gt' => Time.current }
        result = query.ransackify(params, :event)

        expect(result).to include('name_eq' => '$view')
      end
    end
  end

  describe '#range' do
    let(:query_with_range) do
      Class.new(described_class) do
        def build
          AhoyCaptain.event.all
        end

        public :range
      end
    end

    it 'returns a RangeFromParams object' do
      query = query_with_range.new(base_params, nil)

      expect(query.range).to be_a(AhoyCaptain::RangeFromParams)
    end

    it 'uses params to build the range' do
      params = base_params.merge(period: '7d')
      query = query_with_range.new(params, nil)

      expect(query.range).to be_a(AhoyCaptain::RangeFromParams)
    end
  end

  describe '#visit_query' do
    let(:query_with_visit_query) do
      Class.new(described_class) do
        def build
          AhoyCaptain.event.all
        end

        public :visit_query
      end
    end

    it 'returns a VisitQuery' do
      query = query_with_visit_query.new(base_params, nil)

      expect(query.visit_query).to be_a(AhoyCaptain::VisitQuery)
    end
  end

  describe '#event_query' do
    let(:query_with_event_query) do
      Class.new(described_class) do
        def build
          AhoyCaptain.event.all
        end

        public :event_query
      end
    end

    it 'returns an EventQuery' do
      query = query_with_event_query.new(base_params, nil)

      expect(query.event_query).to be_a(AhoyCaptain::EventQuery)
    end
  end
end
