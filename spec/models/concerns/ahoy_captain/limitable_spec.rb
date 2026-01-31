# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Limitable do
  let(:test_class) do
    Class.new do
      include AhoyCaptain::Limitable

      attr_accessor :request, :params

      def initialize(params: {}, variant: [])
        @params = params
        @request = OpenStruct.new(variant: variant)
      end
    end
  end

  describe '#limit' do
    subject(:instance) { test_class.new(params: params, variant: variant) }

    context 'when request variant includes :details' do
      let(:variant) { [:details] }

      context 'with no limit param' do
        let(:params) { {} }

        it 'returns nil' do
          expect(instance.send(:limit)).to be_nil
        end
      end

      context 'with limit param set' do
        let(:params) { { limit: '20' } }

        it 'returns nil regardless of param' do
          expect(instance.send(:limit)).to be_nil
        end
      end
    end

    context 'when request variant does not include :details' do
      let(:variant) { [] }

      context 'with no limit param' do
        let(:params) { {} }

        it 'returns the default limit of 10' do
          expect(instance.send(:limit)).to eq(10)
        end
      end

      context 'with limit param as string' do
        let(:params) { { limit: '25' } }

        it 'returns the limit as an integer' do
          expect(instance.send(:limit)).to eq(25)
        end
      end

      context 'with limit param as integer' do
        let(:params) { { limit: 15 } }

        it 'returns the limit as an integer' do
          expect(instance.send(:limit)).to eq(15)
        end
      end

      context 'with limit param as zero' do
        let(:params) { { limit: '0' } }

        it 'returns 0' do
          expect(instance.send(:limit)).to eq(0)
        end
      end
    end

    context 'with other variants' do
      let(:variant) { [:mobile, :other] }
      let(:params) { {} }

      it 'returns the default limit of 10' do
        expect(instance.send(:limit)).to eq(10)
      end
    end
  end
end
