# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Filter::TagContainerComponent, type: :component do
  subject(:component) do
    described_class.new
  end

  describe '#initialize' do
    it 'creates an instance without arguments' do
      expect(component).to be_a(described_class)
    end
  end
end
