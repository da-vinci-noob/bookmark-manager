# frozen_string_literal: true

class BookmarkImportHtmlService
  class ImportError < StandardError; end

  def initialize(user:, io:)
    @user = user
    @io = io
    @tag_cache = {}
  end

  def call
    html = read_html
    validate_html!(html)

    stats = initial_stats
    existing_urls = existing_urls_for_user

    BookmarkHtmlParser.new(html).parse.each do |entry|
      process_entry(entry, existing_urls, stats)
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

  def validate_html!(html)
    raise ImportError, 'Invalid bookmark HTML format' unless html.match?(/<dl/i)
  end

  def initial_stats
    { imported: 0, duplicates: 0, invalid: 0, total: 0 }
  end

  def existing_urls_for_user
    @user.bookmarks.pluck(:url).to_set { |url| dedupe_key(url) }
  end

  def process_entry(entry, existing_urls, stats)
    stats[:total] += 1
    raw_url = normalize_url(entry[:url])
    url_key = dedupe_key(raw_url)

    return handle_invalid_or_duplicate(raw_url, url_key, existing_urls, stats) if skip_entry?(raw_url, url_key, existing_urls)

    create_bookmark(entry, raw_url, url_key, existing_urls, stats)
  end

  def skip_entry?(raw_url, url_key, existing_urls)
    raw_url.blank? || url_key.blank? || existing_urls.include?(url_key)
  end

  def handle_invalid_or_duplicate(raw_url, url_key, existing_urls, stats)
    stats[:duplicates] += 1 if existing_urls.include?(url_key)
    stats[:invalid] += 1 if raw_url.blank? || url_key.blank?
  end

  def create_bookmark(entry, raw_url, url_key, existing_urls, stats)
    bookmark = build_bookmark(entry, raw_url)
    if bookmark.save
      attach_tags(bookmark, entry[:folders])
      existing_urls << url_key
      stats[:imported] += 1
    else
      stats[:invalid] += 1
    end
  end

  def build_bookmark(entry, raw_url)
    @user.bookmarks.build(url: raw_url, title: normalize_title(entry[:title], raw_url), description: entry[:description])
  end

  def attach_tags(bookmark, folders)
    folders.each do |folder_name|
      tag = find_or_create_tag(folder_name)
      bookmark.tags << tag if tag && bookmark.tags.exclude?(tag)
    end
  end

  def find_or_create_tag(name)
    normalized_name = name.to_s.strip[0, 255]
    return if normalized_name.blank?

    key = normalized_name.downcase
    @tag_cache[key] ||= fetch_or_initialize_tag(key, normalized_name)
  end

  def fetch_or_initialize_tag(key, normalized_name)
    tag = @user.tags.where('LOWER(name) = ?', key).first
    tag || @user.tags.create!(name: normalized_name)
  rescue ActiveRecord::RecordNotUnique
    @user.tags.where('LOWER(name) = ?', key).first
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
