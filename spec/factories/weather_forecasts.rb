# frozen_string_literal: true

FactoryBot.define do
  factory :weather_forecast do
    address { Faker::Address.full_address }
  end
end
