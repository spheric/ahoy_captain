# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Ahoy::EventMethods do
  let(:event_class) { Ahoy::Event }

  describe 'scopes' do
    describe '.page_view' do
      it 'filters by configured view_name' do
        sql = event_class.page_view.to_sql

        expect(sql).to include(AhoyCaptain.config.event[:view_name])
      end

      it 'returns only page view events' do
        visit = Ahoy::Visit.create!(
          visitor_token: SecureRandom.hex(16),
          visit_token: SecureRandom.hex(16),
          started_at: Time.current
        )
        page_view_event = Ahoy::Event.create!(
          visit: visit,
          name: AhoyCaptain.config.event[:view_name],
          time: Time.current,
          properties: { 'controller' => 'pages', 'action' => 'home' }
        )
        custom_event = Ahoy::Event.create!(
          visit: visit,
          name: 'button_click',
          time: Time.current,
          properties: {}
        )

        result = event_class.page_view

        expect(result).to include(page_view_event)
        expect(result).not_to include(custom_event)
      end
    end

    describe '.with_routes' do
      it 'uses the configured url_exists condition' do
        sql = event_class.with_routes.to_sql

        expect(sql).to include('JSONB_EXISTS')
        expect(sql).to include('controller')
        expect(sql).to include('action')
      end

      it 'returns events that have controller and action in properties' do
        visit = Ahoy::Visit.create!(
          visitor_token: SecureRandom.hex(16),
          visit_token: SecureRandom.hex(16),
          started_at: Time.current
        )
        event_with_route = Ahoy::Event.create!(
          visit: visit,
          name: AhoyCaptain.config.event[:view_name],
          time: Time.current,
          properties: { 'controller' => 'pages', 'action' => 'home' }
        )
        event_without_route = Ahoy::Event.create!(
          visit: visit,
          name: AhoyCaptain.config.event[:view_name],
          time: Time.current,
          properties: { 'custom_key' => 'value' }
        )

        result = event_class.with_routes

        expect(result).to include(event_with_route)
        expect(result).not_to include(event_without_route)
      end
    end

    describe '.with_entry_pages' do
      it 'uses time column for joining (UUID compatible)' do
        sql = event_class.with_entry_pages.to_sql

        expect(sql).to include('MIN(ahoy_events.time)')
        expect(sql).to include('entry_pages.min_time = ahoy_events.time')
      end

      it 'does not use id column for joining' do
        sql = event_class.with_entry_pages.to_sql

        expect(sql).not_to include('MIN(ahoy_events.id)')
      end

      it 'generates valid SQL with CTE' do
        sql = event_class.with_entry_pages.to_sql

        expect(sql).to include('WITH')
        expect(sql).to include('entry_pages')
      end

      it 'groups by properties' do
        sql = event_class.with_entry_pages.to_sql

        expect(sql).to include('GROUP BY')
        expect(sql).to include('properties')
      end

      it 'executes without error' do
        expect { event_class.with_entry_pages.to_a }.not_to raise_error
      end
    end

    describe '.with_exit_pages' do
      it 'uses time column for joining (UUID compatible)' do
        sql = event_class.with_exit_pages.to_sql

        expect(sql).to include('MAX(ahoy_events.time)')
        expect(sql).to include('exit_pages.max_time = ahoy_events.time')
      end

      it 'does not use id column for joining' do
        sql = event_class.with_exit_pages.to_sql

        expect(sql).not_to include('MAX(ahoy_events.id)')
      end

      it 'generates valid SQL with CTE' do
        sql = event_class.with_exit_pages.to_sql

        expect(sql).to include('WITH')
        expect(sql).to include('exit_pages')
      end

      it 'groups by properties' do
        sql = event_class.with_exit_pages.to_sql

        expect(sql).to include('GROUP BY')
        expect(sql).to include('properties')
      end

      it 'executes without error' do
        expect { event_class.with_exit_pages.to_a }.not_to raise_error
      end
    end

    describe '.with_url' do
      it 'selects url column based on configuration' do
        sql = event_class.with_url.to_sql

        expect(sql).to include('AS url')
      end
    end

    describe '.distinct_url' do
      it 'applies distinct to url column' do
        sql = event_class.distinct_url.to_sql

        expect(sql).to include('DISTINCT')
      end
    end

    describe '.with_property_values' do
      it 'uses JSONB_EXISTS for property check' do
        sql = event_class.with_property_values('category').to_sql

        expect(sql).to include('JSONB_EXISTS')
        expect(sql).to include('category')
      end

      it 'returns events that have the specified property key' do
        visit = Ahoy::Visit.create!(
          visitor_token: SecureRandom.hex(16),
          visit_token: SecureRandom.hex(16),
          started_at: Time.current
        )
        event_with_property = Ahoy::Event.create!(
          visit: visit,
          name: 'test',
          time: Time.current,
          properties: { 'category' => 'electronics', 'brand' => 'apple' }
        )
        event_without_property = Ahoy::Event.create!(
          visit: visit,
          name: 'test',
          time: Time.current,
          properties: { 'other_key' => 'value' }
        )

        result = event_class.with_property_values('category')

        expect(result).to include(event_with_property)
        expect(result).not_to include(event_without_property)
      end
    end
  end

  describe 'ransackers' do
    describe 'route ransacker' do
      it 'is defined' do
        expect(event_class._ransackers).to have_key('route')
      end

      it 'can be used in ransack queries' do
        q = event_class.ransack(route_cont: 'pages')

        expect(q.result.to_sql).to include('pages')
      end
    end

    describe 'entry_page ransacker' do
      it 'is defined' do
        expect(event_class._ransackers).to have_key('entry_page')
      end

      it 'can be used in ransack queries with entry_pages join' do
        q = event_class.with_entry_pages.ransack(entry_page_cont: 'landing')

        expect(q.result.to_sql).to include('entry_pages.url')
        expect(q.result.to_sql).to include('landing')
      end
    end

    describe 'exit_page ransacker' do
      it 'is defined' do
        expect(event_class._ransackers).to have_key('exit_page')
      end

      it 'can be used in ransack queries with exit_pages join' do
        q = event_class.with_exit_pages.ransack(exit_page_cont: 'checkout')

        expect(q.result.to_sql).to include('exit_pages.url')
        expect(q.result.to_sql).to include('checkout')
      end
    end

    describe 'properties ransacker' do
      it 'is defined' do
        expect(event_class._ransackers).to have_key('properties')
      end
    end

    describe 'goal ransacker' do
      it 'is defined' do
        expect(event_class._ransackers).to have_key('goal')
      end
    end
  end

  describe 'class methods' do
    describe '.ransackable_attributes' do
      it 'includes standard attributes' do
        attributes = event_class.ransackable_attributes

        expect(attributes).to include('id')
        expect(attributes).to include('name')
        expect(attributes).to include('time')
        expect(attributes).to include('properties')
        expect(attributes).to include('visit_id')
        expect(attributes).to include('user_id')
      end

      it 'includes goal attribute' do
        attributes = event_class.ransackable_attributes

        expect(attributes).to include('goal')
      end

      it 'includes ransacker keys' do
        attributes = event_class.ransackable_attributes

        expect(attributes).to include('route')
        expect(attributes).to include('entry_page')
        expect(attributes).to include('exit_page')
      end
    end

    describe '.ransackable_scopes' do
      it 'includes with_property_values' do
        scopes = event_class.ransackable_scopes

        expect(scopes).to include(:with_property_values)
      end

      it 'includes property_value_i_cont' do
        scopes = event_class.ransackable_scopes

        expect(scopes).to include(:property_value_i_cont)
      end
    end

    describe '.ransackable_associations' do
      it 'includes visit' do
        associations = event_class.ransackable_associations

        expect(associations).to include('visit')
      end
    end
  end
end
