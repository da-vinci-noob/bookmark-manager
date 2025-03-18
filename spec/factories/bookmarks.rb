# frozen_string_literal: true

FactoryBot.define do
  factory :bookmark do
    sequence(:title) { |n| "Bookmark Title #{n}" }
    sequence(:url) { |n| "https://example#{n}.com" }
    user
  end
end
