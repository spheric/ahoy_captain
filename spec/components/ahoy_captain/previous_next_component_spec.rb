# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::PreviousNextComponent, type: :component do
  let(:range) { double('Range') }

  subject(:component) do
    described_class.new(range)
  end

  describe '#initialize' do
    it 'sets the range' do
      expect(component.instance_variable_get(:@range)).to eq(range)
    end
  end

  describe '#render?' do
    it 'returns false' do
      expect(component.render?).to be false
    end
  end
end
