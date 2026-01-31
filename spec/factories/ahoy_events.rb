# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    id { SecureRandom.uuid }
    association :visit, factory: :ahoy_visit
    name { "$view" }
    time { Time.current }
    properties do
      {
        "controller" => "pages",
        "action" => "home",
        "url" => "/"
      }
    end

    trait :page_view do
      name { "$view" }
    end

    trait :with_url do
      transient do
        url { "/" }
      end

      properties do
        {
          "controller" => "pages",
          "action" => "show",
          "url" => url
        }
      end
    end

    trait :custom_event do
      transient do
        event_name { "button_click" }
        event_properties { {} }
      end

      name { event_name }
      properties { event_properties }
    end
  end
end
