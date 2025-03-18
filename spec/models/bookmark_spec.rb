# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bookmark do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:bookmark_tags).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:bookmark_tags) }
  end

  describe 'basic validations' do
    subject { build(:bookmark, user: user) }

    let(:user) { create(:user) }

    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'url format validation' do
    let(:user) { create(:user) }

    it 'is valid with http:// protocol' do
      bookmark = build(:bookmark, url: 'http://example.com', user: user)
      expect(bookmark).to be_valid
    end

    it 'is valid with https:// protocol' do
      bookmark = build(:bookmark, url: 'https://example.com', user: user)
      expect(bookmark).to be_valid
    end

    it 'is invalid without proper protocol' do
      bookmark = build(:bookmark, url: 'example.com', user: user)
      expect(bookmark).not_to be_valid
      expect(bookmark.errors[:url]).to include('is invalid')
    end

    it 'is invalid with unsupported protocol' do
      bookmark = build(:bookmark, url: 'ftp://example.com', user: user)
      expect(bookmark).not_to be_valid
      expect(bookmark.errors[:url]).to include('is invalid')
    end
  end

  describe 'url uniqueness validation' do
    let(:user) { create(:user) }

    before { create(:bookmark, url: 'https://example.com', user: user) }

    it 'is invalid with duplicate URL for the same user' do
      bookmark = build(:bookmark, url: 'https://example.com', user: user)
      expect(bookmark).not_to be_valid
      expect(bookmark.errors[:url]).to include('has already been taken')
    end

    it 'is valid with same URL for different user' do
      other_user = create(:user)
      bookmark = build(:bookmark, url: 'https://example.com', user: other_user)
      expect(bookmark).to be_valid
    end

    it 'is case insensitive for URL uniqueness' do
      bookmark = build(:bookmark, url: 'HTTPS://EXAMPLE.COM', user: user)
      expect(bookmark).not_to be_valid
      expect(bookmark.errors[:url]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:user_bookmark) { create(:bookmark, user: user) }
    let(:other_bookmark) { create(:bookmark, user: other_user) }

    describe '.for_user' do
      it 'returns bookmarks for the specified user only' do
        bookmarks = described_class.for_user(user)
        expect(bookmarks).to include(user_bookmark)
        expect(bookmarks).not_to include(other_bookmark)
      end
    end

    describe 'associations' do
      it 'includes tags and bookmark_tags associations' do
        expect(described_class.reflect_on_all_associations(:has_many).map(&:class_name)).to include('Tag', 'BookmarkTag')
      end

      it 'includes user association' do
        expect(described_class.reflect_on_all_associations(:belongs_to).map(&:class_name)).to include('User')
      end
    end
  end
end
