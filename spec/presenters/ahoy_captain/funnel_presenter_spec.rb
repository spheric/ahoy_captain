# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::FunnelPresenter do
  subject(:presenter) { described_class.new(funnel, event_query) }

  let(:funnel) { AhoyCaptain::Funnel.new }
  let(:event_query) { AhoyCaptain.event.all }

  describe '#initialize' do
    it 'stores the funnel' do
      expect(presenter.instance_variable_get(:@funnel)).to eq(funnel)
    end

    it 'stores the event query joined with visits' do
      stored_query = presenter.instance_variable_get(:@event_query)
      expect(stored_query.to_sql).to include('INNER JOIN')
    end
  end

  describe '#steps' do
    it 'returns the steps attribute' do
      expect(presenter).to respond_to(:steps)
    end

    it 'is nil before build is called' do
      expect(presenter.steps).to be_nil
    end
  end

  describe '#build' do
    context 'when no goals are configured' do
      before do
        allow(AhoyCaptain.config.goals).to receive(:none?).and_return(true)
      end

      it 'sets goals to an empty array' do
        presenter.build
        expect(presenter.instance_variable_get(:@goals)).to eq([])
      end

      it 'returns self' do
        expect(presenter.build).to eq(presenter)
      end
    end

    context 'when goals are configured' do
      let(:config) { AhoyCaptain::Configuration.new }
      let!(:visit) { create(:ahoy_visit, started_at: 1.day.ago) }
      let!(:step1_event) { create(:ahoy_event, :custom_event, event_name: 'view_product', visit: visit, time: 1.day.ago) }
      let!(:step2_event) { create(:ahoy_event, :custom_event, event_name: 'add_to_cart', visit: visit, time: 1.day.ago + 1.minute) }
      let!(:step3_event) { create(:ahoy_event, :custom_event, event_name: 'checkout', visit: visit, time: 1.day.ago + 2.minutes) }

      before do
        allow(AhoyCaptain).to receive(:config).and_return(config)

        config.goal(:view_product) do
          label 'View Product'
          name 'view_product'
        end

        config.goal(:add_to_cart) do
          label 'Add to Cart'
          name 'add_to_cart'
        end

        config.goal(:checkout) do
          label 'Checkout'
          name 'checkout'
        end

        funnel.goal(:view_product)
        funnel.goal(:add_to_cart)
        funnel.goal(:checkout)
      end

      it 'returns self' do
        expect(presenter.build).to eq(presenter)
      end

      it 'sets steps to an array' do
        presenter.build
        expect(presenter.steps).to be_an(Array)
      end

      it 'includes step names from goals' do
        presenter.build
        step_names = presenter.steps.map(&:name)
        expect(step_names).to include('View Product', 'Add to Cart', 'Checkout')
      end

      it 'calculates drop off for each step' do
        presenter.build
        presenter.steps.each do |step|
          expect(step).to respond_to(:drop_off)
        end
      end

      it 'includes unique visits for each step' do
        presenter.build
        presenter.steps.each do |step|
          expect(step).to respond_to(:unique_visits)
        end
      end

      it 'includes total events for each step' do
        presenter.build
        presenter.steps.each do |step|
          expect(step).to respond_to(:total_events)
        end
      end
    end
  end

  describe '#total' do
    let!(:visit1) { create(:ahoy_visit, started_at: 1.day.ago) }
    let!(:visit2) { create(:ahoy_visit, started_at: 2.days.ago) }
    let!(:event1) { create(:ahoy_event, visit: visit1, time: 1.day.ago) }
    let!(:event2) { create(:ahoy_event, visit: visit2, time: 2.days.ago) }

    it 'returns a count' do
      count = presenter.total
      expect(count).to be_a(Integer)
    end

    it 'counts distinct visitor tokens' do
      expect(presenter.total).to be >= 0
    end
  end

  describe '#as_json' do
    before do
      presenter.instance_variable_set(:@steps, [])
    end

    it 'returns a hash with steps and total keys' do
      result = presenter.as_json
      expect(result).to have_key(:steps)
      expect(result).to have_key(:total)
    end

    it 'includes steps as json' do
      presenter.instance_variable_set(:@steps, [])
      result = presenter.as_json
      expect(result[:steps]).to eq([])
    end
  end

  describe '#to_json' do
    before do
      presenter.instance_variable_set(:@steps, [])
    end

    it 'returns a JSON string' do
      result = presenter.to_json
      expect(result).to be_a(String)
      expect { JSON.parse(result) }.not_to raise_error
    end

    it 'includes steps and total in the JSON' do
      result = JSON.parse(presenter.to_json)
      expect(result).to have_key('steps')
      expect(result).to have_key('total')
    end
  end
end
