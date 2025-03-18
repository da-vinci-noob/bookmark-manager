# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag #{n}" }
    color { "##{SecureRandom.hex(3)}" } # Random hex color
    user
  end
end
