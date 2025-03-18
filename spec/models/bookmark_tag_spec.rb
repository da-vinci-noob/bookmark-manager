# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarkTag do
  describe 'associations' do
    it { is_expected.to belong_to(:bookmark) }
    it { is_expected.to belong_to(:tag) }
  end

  describe 'creation' do
    let(:user) { create(:user) }
    let(:bookmark) { create(:bookmark, user: user) }
    let(:tag) { create(:tag, user: user) }

    it 'successfully creates a valid bookmark tag' do
      bookmark_tag = described_class.new(bookmark: bookmark, tag: tag)
      expect(bookmark_tag).to be_valid
      expect(bookmark_tag.save).to be true
    end

    it 'associates a bookmark with multiple tags' do
      tag1, tag2 = create_list(:tag, 2, user: user)

      described_class.create(bookmark: bookmark, tag: tag1)
      described_class.create(bookmark: bookmark, tag: tag2)

      expect(bookmark.tags.count).to eq(2)
      expect(bookmark.tags).to include(tag1, tag2)
    end

    it 'associates a tag with multiple bookmarks' do
      bookmark1, bookmark2 = create_list(:bookmark, 2, user: user)

      described_class.create(bookmark: bookmark1, tag: tag)
      described_class.create(bookmark: bookmark2, tag: tag)

      expect(tag.bookmarks.count).to eq(2)
      expect(tag.bookmarks).to include(bookmark1, bookmark2)
    end
  end

  describe 'deletion' do
    let(:user) { create(:user) }
    let(:bookmark) { create(:bookmark, user: user) }
    let(:tag) { create(:tag, user: user) }
    let!(:bookmark_tag) { create(:bookmark_tag, bookmark: bookmark, tag: tag) }

    it 'is removed when the bookmark is deleted' do
      expect do
        bookmark.destroy
      end.to change(described_class, :count).by(-1)

      expect(described_class.exists?(bookmark_tag.id)).to be false
    end

    it 'is removed when the tag is deleted' do
      expect do
         tag.destroy
      end.to change(described_class, :count).by(-1)

      expect(described_class.exists?(bookmark_tag.id)).to be false
    end
  end
end
