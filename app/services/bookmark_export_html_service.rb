# frozen_string_literal: true

class BookmarkExportHtmlService
  def initialize(bookmarks:)
    @bookmarks = bookmarks
  end

  def call
    body = @bookmarks.map { |bookmark| bookmark_html(bookmark) }
                     .join("\n")

    <<~HTML
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file. -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
      #{body}
      </DL><p>
    HTML
  end

  private

  # rubocop:disable Metrics/AbcSize
  def bookmark_html(bookmark)
    title = ERB::Util.html_escape(bookmark.title.presence || bookmark.url)
    url = ERB::Util.html_escape(bookmark.url)
    add_date = bookmark.created_at.to_i
    tags_array = bookmark.tags.map(&:name)
    tags_array.sort!
    tags = tags_array.join(',')
    tags_attr = tags.present? ? %( TAGS="#{ERB::Util.html_escape(tags)}") : ''
    description = bookmark.description.present? ? "<DD>#{ERB::Util.html_escape(bookmark.description)}" : ''

    %(<DT><A HREF="#{url}" ADD_DATE="#{add_date}"#{tags_attr}>#{title}</A>\n#{description})
  end
  # rubocop:enable Metrics/AbcSize
end
