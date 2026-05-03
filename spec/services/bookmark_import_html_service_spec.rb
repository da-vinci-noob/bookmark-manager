# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarkImportHtmlService do
  let(:user) { create(:user) }

  describe '#call' do
    let(:html) do
      <<~HTML
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <DL><p>
          <DT><H3>Engineering</H3>
          <DL><p>
            <DT><A HREF="https://rubyonrails.org">Ruby on Rails</A>
          </DL><p>
          <DT><A HREF="https://existing.example.com">Existing</A>
        </DL><p>
      HTML
    end

    before do
      create(:bookmark, user:, url: 'https://existing.example.com', title: 'Already There')
    end

    it 'imports bookmarks and maps folders to tags' do
      result = described_class.new(user:, io: StringIO.new(html)).call

      expect(result).to include(imported: 1, duplicates: 1, invalid: 0, total: 2)
      bookmark = user.bookmarks.find_by(url: 'https://rubyonrails.org')
      expect(bookmark).to be_present
      expect(bookmark.tags.pluck(:name)).to include('Engineering')
    end

    it 'raises an import error for empty content' do
      expect do
        described_class.new(user:, io: StringIO.new('   ')).call
      end.to raise_error(BookmarkImportHtmlService::ImportError, 'Uploaded file is empty')
    end
  end
end
