# frozen_string_literal: true

FactoryBot.define do
  factory :bookmark_tag do
    bookmark
    tag
  end
end
