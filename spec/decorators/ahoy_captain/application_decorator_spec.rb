# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::ApplicationDecorator do
  let(:object) { double('object', some_method: 'value') }
  let(:view_context) { double('view_context', params: params, search_params: {}) }
  let(:context) { double('context', view_context: view_context, request: double('request')) }
  let(:params) { ActionController::Parameters.new({}) }

  describe '.csv_map' do
    it 'raises NotImplementedError' do
      expect { described_class.csv_map }.to raise_error(NotImplementedError)
    end
  end

  describe '.to_csv' do
    let(:test_decorator_class) do
      Class.new(described_class) do
        def self.csv_map(params = {})
          { 'Name' => :name, 'Count' => :count }
        end

        def name
          object.name
        end

        def count
          object.count
        end
      end
    end

    let(:item1) { double('item1', name: 'Item 1', count: 10) }
    let(:item2) { double('item2', name: 'Item 2', count: 20) }
    let(:collection) { [item1, item2] }
    let(:csv_context) { double('context', view_context: view_context, request: double('request'), params: params) }

    it 'generates CSV with headers and rows' do
      csv = test_decorator_class.to_csv(collection, csv_context)

      expect(csv).to include('Name')
      expect(csv).to include('Count')
      expect(csv).to include('Item 1')
      expect(csv).to include('Item 2')
      expect(csv).to include('10')
      expect(csv).to include('20')
    end
  end

  describe '#initialize' do
    subject(:decorator) { described_class.new(object, context) }

    it 'stores the object' do
      expect(decorator.object).to eq(object)
    end
  end

  describe 'delegate_missing_to' do
    subject(:decorator) { described_class.new(object, context) }

    it 'delegates missing methods to object' do
      expect(decorator.some_method).to eq('value')
    end
  end

  describe 'private methods' do
    subject(:decorator) { described_class.new(object, context) }

    describe '#h' do
      it 'returns the view context' do
        expect(decorator.send(:h)).to eq(view_context)
      end
    end

    describe '#params' do
      it 'returns params from view context' do
        expect(decorator.send(:params)).to eq(params)
      end
    end

    describe '#search_query' do
      let(:view_context) { double('view_context', params: params, search_params: { q: { existing: 'value' } }) }

      it 'builds a query string with new parameters' do
        result = decorator.send(:search_query, new_param: 'test')

        expect(result).to include('new_param')
        expect(result).to include('test')
      end
    end

    describe '#request' do
      let(:request) { double('request') }
      let(:context) { double('context', view_context: view_context, request: request) }

      it 'returns the request from context' do
        expect(decorator.send(:request)).to eq(request)
      end
    end
  end
end
