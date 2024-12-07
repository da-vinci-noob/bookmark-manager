# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  has_many :bookmarks, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  validate :check_registrations_enabled, on: :create

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def check_registrations_enabled
    return unless ENV['DISABLE_REGISTRATIONS']

    errors.add(:base, 'New user registrations are currently disabled')
  end
end
