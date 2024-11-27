# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :bookmark_tags, dependent: :destroy
  has_many :bookmarks, through: :bookmark_tags

  validates :name, presence: true, uniqueness: true
  validates :color, format: { with: /\A#([0-9A-Fa-f]{3}){1,2}\z/ }, allow_blank: true
end
