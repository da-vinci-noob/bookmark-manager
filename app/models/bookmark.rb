# frozen_string_literal: true

class Bookmark < ApplicationRecord
  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :title, presence: true
end
