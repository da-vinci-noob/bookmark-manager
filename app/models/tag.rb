# frozen_string_literal: true

class Tag < ApplicationRecord
  has_and_belongs_to_many :bookmarks

  validates :name, presence: true, uniqueness: true
  validates :color, format: { with: /\A#([0-9A-Fa-f]{3}){1,2}\z/, message: 'must be a valid hex color code' }, allow_blank: true
end
