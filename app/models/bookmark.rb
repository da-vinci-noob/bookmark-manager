# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user
  has_many :bookmark_tags, dependent: :destroy
  has_many :tags, through: :bookmark_tags

  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :title, presence: true

  scope :for_user, ->(user) { where(user:) }

  # Prevent N+1 queries
  scope :with_associations, -> { includes(:tags, :bookmark_tags) }
end
