# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::CompareMode do
  let(:test_class) do
    Class.new do
      include AhoyCaptain::CompareMode

      attr_accessor :params

      def initialize(params = {})
        @params = params
      end
    end
  end

  let(:controller_class) do
    Class.new(ActionController::Base) do
      include AhoyCaptain::CompareMode

      attr_accessor :params

      def initialize(params = {})
        @params = params
      end
    end
  end

  describe '.included' do
    context 'when included in a class that inherits from ActionController::Base' do
      it 'defines compare_mode? as a helper method' do
        expect(controller_class._helper_methods).to include(:compare_mode?)
      end

      it 'defines comparison_label as a helper method' do
        expect(controller_class._helper_methods).to include(:comparison_label)
      end
    end

    context 'when included in a non-controller class' do
      it 'does not raise an error' do
        expect { test_class }.not_to raise_error
      end
    end
  end

  describe '#compare_mode?' do
    subject(:instance) { test_class.new(params) }

    context 'when comparison is enabled with previous period' do
      let(:params) { { comparison: 'previous', period: '30d' } }

      it 'returns true' do
        expect(instance.compare_mode?).to be true
      end
    end

    context 'when comparison is enabled with year comparison' do
      let(:params) { { comparison: 'year', period: '30d' } }

      it 'returns true' do
        expect(instance.compare_mode?).to be true
      end
    end

    context 'when comparison is set to true' do
      let(:params) { { comparison: 'true', period: '30d' } }

      it 'returns true' do
        expect(instance.compare_mode?).to be true
      end
    end

    context 'when comparison is not set' do
      let(:params) { { period: '30d' } }

      it 'returns a falsy value' do
        expect(instance.compare_mode?).to be_falsy
      end
    end

    context 'when comparison is set to an invalid value' do
      let(:params) { { comparison: 'invalid', period: '30d' } }

      it 'returns a falsy value' do
        expect(instance.compare_mode?).to be_falsy
      end
    end

    context 'when in realtime mode with comparison enabled' do
      let(:params) { { comparison: 'previous', period: 'realtime' } }

      it 'returns false because realtime does not support comparison' do
        expect(instance.compare_mode?).to be false
      end
    end

    context 'when using custom comparison dates' do
      let(:params) do
        {
          period: '30d',
          compare_to_start_date: 2.months.ago.to_s,
          compare_to_end_date: 1.month.ago.to_s
        }
      end

      it 'returns true' do
        expect(instance.compare_mode?).to be true
      end
    end
  end

  describe '#comparison_mode' do
    subject(:instance) { test_class.new(params) }

    let(:params) { { comparison: 'previous', period: '30d' } }

    it 'returns a ComparisonMode instance' do
      expect(instance.comparison_mode).to be_a(AhoyCaptain::ComparisonMode)
    end

    it 'memoizes the result' do
      first_call = instance.comparison_mode
      second_call = instance.comparison_mode

      expect(first_call).to be(second_call)
    end
  end
end
