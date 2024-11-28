# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :user
  has_many :bookmark_tags, dependent: :destroy
  has_many :bookmarks, through: :bookmark_tags

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :color, format: { with: /\A#([0-9A-Fa-f]{3}){1,2}\z/ }, allow_blank: true

  scope :for_user, ->(user) { where(user:) }

  # Prevent N+1 queries
  scope :with_bookmarks, -> { includes(:bookmarks, :bookmark_tags) }
end
