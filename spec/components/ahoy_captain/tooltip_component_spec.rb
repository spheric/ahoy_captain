# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::TooltipComponent, type: :component do
  let(:amount) { 1000 }

  subject(:component) do
    described_class.new(amount: amount)
  end

  describe '#initialize' do
    it 'sets the amount' do
      expect(component.send(:amount)).to eq(amount)
    end
  end

  describe '#abbreviate' do
    context 'when amount is less than 1000' do
      let(:amount) { 500 }

      it 'returns the amount as string' do
        expect(component.abbreviate).to eq('500')
      end
    end

    context 'when amount is exactly 1000' do
      let(:amount) { 1000 }

      it 'abbreviates with k suffix' do
        expect(component.abbreviate).to eq('1k')
      end
    end

    context 'when amount is in thousands' do
      let(:amount) { 5500 }

      it 'abbreviates with k suffix' do
        expect(component.abbreviate).to eq('5.5k')
      end
    end

    context 'when amount is in millions' do
      let(:amount) { 1500000 }

      it 'abbreviates with m suffix' do
        expect(component.abbreviate).to eq('1.5m')
      end
    end

    context 'when amount is in billions' do
      let(:amount) { 2500000000 }

      it 'abbreviates with b suffix' do
        expect(component.abbreviate).to eq('2.5b')
      end
    end

    context 'when amount is zero' do
      let(:amount) { 0 }

      it 'returns zero as string' do
        expect(component.abbreviate).to eq('0')
      end
    end

    context 'when amount is a string number' do
      let(:amount) { '2000' }

      it 'converts and abbreviates' do
        expect(component.abbreviate).to eq('2k')
      end
    end
  end
end
