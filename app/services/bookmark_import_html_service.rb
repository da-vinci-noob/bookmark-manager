# frozen_string_literal: true

require 'nokogiri'
require 'set'

class BookmarkImportHtmlService
  class ImportError < StandardError; end

  def initialize(user:, io:)
    @user = user
    @io = io
    @tag_cache = {}
  end

  def call
    html = read_html
    raise ImportError, 'Invalid bookmark HTML format' unless html.match?(/<dl/i)

    existing_urls = @user.bookmarks.pluck(:url).map { |url| dedupe_key(url) }.to_set
    stats = { imported: 0, duplicates: 0, invalid: 0, total: 0 }

    parse_entries(html).each do |entry|
      stats[:total] += 1
      raw_url = normalize_url(entry[:url])
      url_key = dedupe_key(raw_url)

      if raw_url.blank? || url_key.blank? || existing_urls.include?(url_key)
        stats[:duplicates] += 1 if existing_urls.include?(url_key)
        stats[:invalid] += 1 if raw_url.blank? || url_key.blank?
        next
      end

      bookmark = @user.bookmarks.build(
        url: raw_url,
        title: normalize_title(entry[:title], raw_url),
        description: entry[:description]
      )

      unless bookmark.save
        stats[:invalid] += 1
        next
      end

      attach_tags(bookmark, entry[:folders])
      existing_urls << url_key
      stats[:imported] += 1
    end

    stats
  end

  private

  def read_html
    @io.rewind if @io.respond_to?(:rewind)
    raw = @io.read.to_s
    raise ImportError, 'Uploaded file is empty' if raw.strip.empty?

    raw
  end

  def parse_entries(html)
    entries = []
    stack = []
    pending_folder = nil
    last_entry = nil

    html.each_line do |line|
      stripped = line.strip
      next if stripped.empty?

      fragment = Nokogiri::HTML.fragment(stripped)

      heading = fragment.at_css('h3')
      if heading
        pending_folder = sanitize_folder_name(heading.text)
        next
      end

      if stripped.match?(/<dl\b/i)
        stack << pending_folder if pending_folder.present?
        pending_folder = nil
        next
      end

      if stripped.match?(%r{</dl>}i)
        stack.pop if stack.any?
        next
      end

      anchor = fragment.at_css('a[href]')
      if anchor
        last_entry = {
          url:         anchor['href'],
          title:       anchor.text.to_s.strip,
          description: nil,
          folders:     stack.dup
        }
        entries << last_entry
        next
      end

      description = fragment.at_css('dd')
      last_entry[:description] = description.text.to_s.strip.presence if description && last_entry
    end

    entries
  end

  def attach_tags(bookmark, folders)
    folders.each do |folder_name|
      tag = find_or_create_tag(folder_name)
      bookmark.tags << tag if tag && !bookmark.tags.include?(tag)
    end
  end

  def find_or_create_tag(name)
    normalized_name = sanitize_folder_name(name)
    return nil if normalized_name.blank?

    key = normalized_name.downcase
    return @tag_cache[key] if @tag_cache.key?(key)

    tag = @user.tags.where('LOWER(name) = ?', key).first
    tag ||= @user.tags.create!(name: normalized_name)
    @tag_cache[key] = tag
  rescue ActiveRecord::RecordNotUnique
    @tag_cache[key] = @user.tags.where('LOWER(name) = ?', key).first
  end

  def sanitize_folder_name(value)
    value.to_s.strip[0, 255]
  end

  def normalize_url(url)
    url.to_s.strip
  end

  def dedupe_key(url)
    normalize_url(url).downcase
  end

  def normalize_title(title, fallback_url)
    text = title.to_s.strip
    text.present? ? text[0, 255] : fallback_url[0, 255]
  end
end
