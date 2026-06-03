# frozen_string_literal: true

require 'csv'

class BookmarkExportCsvService
  def initialize(bookmarks:)
    @bookmarks = bookmarks
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << %w[url title description tags created_at updated_at]

      @bookmarks.each do |bookmark|
        tags_array = bookmark.tags.map(&:name)
        tags_array.sort!
        csv << [bookmark.url, bookmark.title, bookmark.description, tags_array.join(', '), bookmark.created_at.iso8601, bookmark.updated_at.iso8601]
      end
    end
  end
end
