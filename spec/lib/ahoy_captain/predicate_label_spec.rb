# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::PredicateLabel do
  describe '.[]' do
    context 'with configured predicate labels' do
      it 'returns the label for :eq' do
        expect(described_class[:eq]).to eq('equals')
      end

      it 'returns the label for :not_eq' do
        expect(described_class[:not_eq]).to eq('not equals')
      end

      it 'returns the label for :cont' do
        expect(described_class[:cont]).to eq('contains')
      end

      it 'returns the label for :in' do
        expect(described_class[:in]).to eq('in')
      end

      it 'returns the label for :not_in' do
        expect(described_class[:not_in]).to eq('not in')
      end
    end

    context 'with string keys' do
      it 'converts string to symbol for lookup' do
        expect(described_class['eq']).to eq('equals')
      end

      it 'converts string to symbol for :not_eq' do
        expect(described_class['not_eq']).to eq('not equals')
      end
    end

    context 'with unknown predicates' do
      it 'titleizes the unknown predicate' do
        expect(described_class[:unknown_predicate]).to eq('Unknown Predicate')
      end

      it 'titleizes string unknown predicates' do
        expect(described_class['some_other_value']).to eq('Some Other Value')
      end

      it 'titleizes single word predicates' do
        expect(described_class[:custom]).to eq('Custom')
      end
    end
  end
end
