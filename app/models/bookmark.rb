# frozen_string_literal: true

class Bookmark < ApplicationRecord
  has_and_belongs_to_many :tags

  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :title, presence: true
end
