# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
    it { is_expected.to have_many(:tags).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }

    context 'with email format' do
      it 'is valid with proper email format' do
        user = build(:user, email: 'user@example.com')
        expect(user).to be_valid
      end

      it 'is invalid with improper email format' do
        user = build(:user, email: 'invalid-email')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('is invalid')
      end
    end

    context 'with password requirements' do
      it 'is valid with password of minimum length' do
        user = build(:user, password: 'password', password_confirmation: 'password')
        expect(user).to be_valid
      end

      it 'is invalid with password shorter than minimum length' do
        user = build(:user, password: 'short', password_confirmation: 'short')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
      end

      it 'is invalid with mismatched password confirmation' do
        user = build(:user, password: 'password', password_confirmation: 'different')
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end

    context 'when updating an existing user' do
      let(:user) { create(:user) }

      it 'does not require password when not changing it' do
        # Save the user first
        user.save
        # Then update without password
        user.email = 'new_email@example.com'
        expect(user).to be_valid
      end

      it 'requires password confirmation when changing password' do
        # Save the user first
        user.save
        # Then update with password but mismatched confirmation
        user.password = 'new_password'
        user.password_confirmation = 'different_password'
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end
  end

  describe 'registration restrictions' do
    before do
      allow(ENV).to receive(:[]).with('DISABLE_REGISTRATIONS').and_return('true')
    end

    it 'prevents registration when disabled' do
      user = build(:user)
      expect(user).not_to be_valid
      expect(user.errors[:base]).to include('New user registrations are currently disabled')
    end

    it 'allows registration when enabled' do
      allow(ENV).to receive(:[]).with('DISABLE_REGISTRATIONS').and_return(nil)
      user = build(:user)
      expect(user).to be_valid
    end
  end

  describe 'delete associated bookmark/tags when user is deleted' do
    let(:user) { create(:user) }
    let(:bookmark) { create(:bookmark, user: user) }
    let(:tag) { create(:tag, user: user) }

    it 'deletes associated bookmarks when user is deleted' do
      bookmark # Reference the bookmark to ensure it's created before the test
      expect { user.destroy }
        .to change(Bookmark, :count).by(-1)
    end

    it 'deletes associated tags when user is deleted' do
      tag # Reference the tag to ensure it's created before the test
      expect { user.destroy }
        .to change(Tag, :count).by(-1)
    end
  end
end
