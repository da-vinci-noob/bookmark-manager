# frozen_string_literal: true

class Bookmark < ApplicationRecord
  has_many :bookmark_tags, dependent: :destroy
  has_many :tags, through: :bookmark_tags

  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :title, presence: true
end
