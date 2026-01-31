# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_visit, class: 'Ahoy::Visit' do
    id { SecureRandom.uuid }
    visitor_token { SecureRandom.hex(16) }
    visit_token { SecureRandom.hex(16) }
    started_at { Time.current }
    ip { "192.168.1.#{rand(1..255)}" }
    user_agent { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
    browser { %w[Chrome Firefox Safari Edge].sample }
    os { %w[Windows macOS Linux iOS Android].sample }
    device_type { %w[Desktop Mobile Tablet].sample }
    country { %w[United\ States Canada United\ Kingdom Germany France].sample }
    region { %w[California New\ York Texas Florida].sample }
    city { %w[San\ Francisco New\ York Los\ Angeles Chicago].sample }
    utm_source { nil }
    utm_medium { nil }
    utm_campaign { nil }
    utm_term { nil }
    utm_content { nil }
    referrer { nil }
    referring_domain { nil }
    landing_page { "/" }

    trait :with_utm do
      utm_source { %w[google facebook twitter linkedin].sample }
      utm_medium { %w[cpc organic email social].sample }
      utm_campaign { %w[summer_sale brand awareness].sample }
    end

    trait :with_referrer do
      referrer { "https://google.com/search?q=test" }
      referring_domain { "google.com" }
    end

    trait :mobile do
      device_type { "Mobile" }
      os { %w[iOS Android].sample }
    end

    trait :desktop do
      device_type { "Desktop" }
      os { %w[Windows macOS Linux].sample }
    end
  end
end
