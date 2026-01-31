# Ahoy Captain Testing Plan

## Overview

This document outlines the comprehensive testing strategy for the ahoy_captain gem. The gem is a Rails engine providing analytics dashboards using Ahoy data.

## Completed Work

### Security Patches Applied
1. **`lib/ahoy_captain/ahoy/event_methods.rb`** - Fixed UUID compatibility
   - Changed `MIN/MAX(id)` to `MIN/MAX(time)` for `with_entry_pages` and `with_exit_pages` scopes

2. **`app/queries/ahoy_captain/entry_pages_query.rb`** - Fixed UUID compatibility
   - Changed `min(id)` to `min(time)`

3. **`app/queries/ahoy_captain/exit_pages_query.rb`** - Fixed UUID compatibility
   - Changed `max(id)` to `max(time)`

4. **`app/queries/ahoy_captain/campaign_query.rb`** - SQL injection fix
   - Added `ALLOWED_CAMPAIGN_TYPES` allowlist

5. **`app/queries/ahoy_captain/device_query.rb`** - SQL injection fix
   - Added `ALLOWED_DEVICE_TYPES` allowlist

6. **`app/controllers/ahoy_captain/filters/locations_controller.rb`** - SQL injection fix
   - Added `ALLOWED_TYPES` allowlist

7. **`app/controllers/ahoy_captain/filters/utms_controller.rb`** - SQL injection fix
   - Added `ALLOWED_TYPES` allowlist

8. **`app/controllers/ahoy_captain/filters/properties/values_controller.rb`** - SQL injection fix
   - Added key sanitization with regex validation

9. **`app/controllers/ahoy_captain/application_controller.rb`** - Fixed Pagy and routing
   - Changed `Pagy::Method` to `Pagy::Backend`
   - Changed `Rails.application.routes` to `AhoyCaptain::Engine.routes` in `act_like_an_spa`

10. **`app/components/ahoy_captain/stats/comparable_container_component.rb`** - Nil safety
    - Added nil guards for `percentage` and `tooltip` methods

### Specs Already Written
- `spec/lib/ahoy_captain/period_collection_spec.rb` ✅
- `spec/lib/ahoy_captain/configuration_spec.rb` ✅
- `spec/queries/ahoy_captain/campaign_query_spec.rb` ✅
- `spec/queries/ahoy_captain/device_query_spec.rb` ✅
- `spec/controllers/ahoy_captain/filters/locations_controller_spec.rb` ✅
- `spec/controllers/ahoy_captain/filters/utms_controller_spec.rb` ✅

---

## Remaining Testing Tasks

### Priority 1: Security Specs (Critical)
- [ ] `spec/controllers/ahoy_captain/filters/properties/values_controller_spec.rb`
  - Test key sanitization regex
  - Test SQL injection prevention
  - Test nil/empty handling

### Priority 2: Core Lib Specs
- [ ] `spec/lib/ahoy_captain_spec.rb`
  - Test `.configure` block
  - Test `.config` accessor
  - Test `.cache` (enabled vs disabled)
  - Test `.event` and `.visit` model accessors
  - Test `.none` placeholder

- [ ] `spec/lib/ahoy_captain/goals_spec.rb`
  - Test Goal class
  - Test GoalCollection

- [ ] `spec/lib/ahoy_captain/funnels_spec.rb`
  - Test Funnel class
  - Test FunnelCollection

- [ ] `spec/lib/ahoy_captain/filters_configuration_spec.rb`
  - Test FiltersConfiguration
  - Test Filter class
  - Test FilterCollection

- [ ] `spec/lib/ahoy_captain/predicate_label_spec.rb`
  - Test predicate label formatting

- [ ] `spec/lib/ahoy_captain/ahoy/event_methods_spec.rb`
  - Test `page_view` scope
  - Test `with_routes` scope
  - Test `with_entry_pages` scope (UUID compatible)
  - Test `with_exit_pages` scope (UUID compatible)
  - Test ransackers

- [ ] `spec/lib/ahoy_captain/ahoy/visit_methods_spec.rb`
  - Test scopes
  - Test ransackers

### Priority 3: Query Specs
- [ ] `spec/queries/ahoy_captain/application_query_spec.rb`
  - Test base query behavior
  - Test ransack integration

- [ ] `spec/queries/ahoy_captain/visit_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/event_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/source_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/top_page_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/entry_pages_query_spec.rb` (UUID fix)
- [ ] `spec/queries/ahoy_captain/exit_pages_query_spec.rb` (UUID fix)
- [ ] `spec/queries/ahoy_captain/city_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/region_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/country_query_spec.rb`

### Priority 4: Stats Query Specs
- [ ] `spec/queries/ahoy_captain/stats/base_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/stats/unique_visitors_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/stats/total_visitors_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/stats/total_pageviews_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/stats/bounce_rates_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/stats/average_visit_duration_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/stats/views_per_visit_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/stats/average_views_per_visit_query_spec.rb`
- [ ] `spec/queries/ahoy_captain/stats/visit_duration_query_spec.rb`

### Priority 5: Model Specs
- [ ] `spec/models/ahoy_captain/range_from_params_spec.rb`
- [ ] `spec/models/ahoy_captain/comparison_mode_spec.rb` (exists, extend)
- [ ] `spec/models/ahoy_captain/filter_parser_spec.rb` (exists, extend)
- [ ] `spec/models/ahoy_captain/widget_spec.rb` (exists, extend)
- [ ] `spec/models/ahoy_captain/export_spec.rb`
- [ ] `spec/models/ahoy_captain/rangeable_spec.rb`

### Priority 6: Controller Specs
- [ ] `spec/controllers/ahoy_captain/application_controller_spec.rb` (exists, extend)
- [ ] `spec/controllers/ahoy_captain/roots_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/stats_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/top_pages_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/entry_pages_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/exit_pages_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/sources_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/campaigns_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/devices_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/locations/*_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/realtimes_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/exports_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/goals_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/funnels_controller_spec.rb`
- [ ] `spec/controllers/ahoy_captain/properties_controller_spec.rb`

### Priority 7: Presenter Specs
- [ ] `spec/presenters/ahoy_captain/dashboard_presenter_spec.rb`
- [ ] `spec/presenters/ahoy_captain/goals_presenter_spec.rb`
- [ ] `spec/presenters/ahoy_captain/funnel_presenter_spec.rb`

### Priority 8: Decorator Specs
- [ ] `spec/decorators/ahoy_captain/application_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/campaign_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/device_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/source_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/top_page_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/entry_page_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/exit_page_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/city_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/region_decorator_spec.rb`
- [ ] `spec/decorators/ahoy_captain/country_decorator_spec.rb`

### Priority 9: Component Specs
- [ ] `spec/components/ahoy_captain/stats/comparable_container_component_spec.rb`
- [ ] `spec/components/ahoy_captain/filter/dropdown_component_spec.rb`
- [ ] `spec/components/ahoy_captain/tables/*_component_spec.rb`

### Priority 10: Concern Specs
- [ ] `spec/models/concerns/ahoy_captain/compare_mode_spec.rb`
- [ ] `spec/models/concerns/ahoy_captain/limitable_spec.rb`
- [ ] `spec/models/concerns/ahoy_captain/range_options_spec.rb`
- [ ] `spec/queries/concerns/ahoy_captain/comparable_query_spec.rb`
- [ ] `spec/queries/concerns/ahoy_captain/comparable_queries_spec.rb`
- [ ] `spec/queries/concerns/ahoy_captain/lazy_comparable_query_spec.rb`

---

## Test Setup Requirements

### Factories Needed
```ruby
# spec/factories/ahoy_visits.rb
FactoryBot.define do
  factory :ahoy_visit, class: 'Ahoy::Visit' do
    id { SecureRandom.uuid }  # UUID support
    visitor_token { SecureRandom.hex(16) }
    visit_token { SecureRandom.hex(16) }
    started_at { Time.current }
    ip { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    browser { %w[Chrome Firefox Safari Edge].sample }
    os { %w[Windows macOS Linux iOS Android].sample }
    device_type { %w[Desktop Mobile Tablet].sample }
    country { Faker::Address.country }
    region { Faker::Address.state }
    city { Faker::Address.city }
    utm_source { [nil, 'google', 'facebook', 'twitter'].sample }
    utm_medium { [nil, 'cpc', 'organic', 'email'].sample }
    utm_campaign { [nil, 'summer_sale', 'brand'].sample }
  end
end

# spec/factories/ahoy_events.rb
FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    id { SecureRandom.uuid }  # UUID support
    association :visit, factory: :ahoy_visit
    name { '$view' }
    time { Time.current }
    properties do
      {
        controller: 'pages',
        action: 'home',
        url: '/'
      }
    end
  end
end
```

### RuboCop Configuration
Add to `.rubocop.yml`:
```yaml
require:
  - rubocop-rspec
  - rubocop-factory_bot

RSpec/ExampleLength:
  Max: 15

RSpec/MultipleExpectations:
  Max: 5

RSpec/NestedGroups:
  Max: 4
```

---

## Running Tests

```bash
cd /Users/matthewgardner/Personal/ahoy_captain

# Install dependencies
bundle install

# Setup test database
cd spec/dummy && bundle exec rails db:create db:migrate RAILS_ENV=test && cd ../..

# Run all specs
bundle exec rspec

# Run specific category
bundle exec rspec spec/lib/
bundle exec rspec spec/queries/
bundle exec rspec spec/controllers/

# Run with coverage
COVERAGE=true bundle exec rspec
```

---

## Notes

- All queries must be tested with UUID primary keys (the main app uses UUIDs)
- Security specs should test SQL injection prevention explicitly
- Use `let_it_be` from test-prof for expensive setup where appropriate
- Keep specs focused and fast - prefer unit tests over integration
- Mock external dependencies where possible
