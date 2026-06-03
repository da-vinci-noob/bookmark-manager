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
    validate_html!(html)

    stats = initial_stats
    existing_urls = existing_urls_for_user

    parse_entries(html).each do |entry|
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
    @user.bookmarks.pluck(:url).map { |url| dedupe_key(url) }.to_set
  end

  def process_entry(entry, existing_urls, stats)
    stats[:total] += 1
    raw_url = normalize_url(entry[:url])
    url_key = dedupe_key(raw_url)

    if raw_url.blank? || url_key.blank? || existing_urls.include?(url_key)
      stats[:duplicates] += 1 if existing_urls.include?(url_key)
      stats[:invalid] += 1 if raw_url.blank? || url_key.blank?
      return
    end

    bookmark = build_bookmark(entry, raw_url)
    unless bookmark.save
      stats[:invalid] += 1
      return
    end

    attach_tags(bookmark, entry[:folders])
    existing_urls << url_key
    stats[:imported] += 1
  end

  def build_bookmark(entry, raw_url)
    @user.bookmarks.build(
      url: raw_url,
      title: normalize_title(entry[:title], raw_url),
      description: entry[:description]
    )
  end

  def parse_entries(html)
    entries = []
    stack = []
    pending_folder = nil
    last_entry = nil

    html.each_line do |line|
      last_entry, pending_folder, stack = process_line(line, entries, last_entry, pending_folder, stack)
    end

    entries
  end

  def process_line(line, entries, last_entry, pending_folder, stack)
    stripped = line.strip
    return [last_entry, pending_folder, stack] if stripped.empty?

    fragment = Nokogiri::HTML.fragment(stripped)

    heading = fragment.at_css('h3')
    return [last_entry, sanitize_folder_name(heading.text), stack] if heading

    if open_folder?(stripped)
      return [last_entry, nil, stack_with_pending_folder(stack, pending_folder)]
    end

    if close_folder?(stripped)
      return [last_entry, pending_folder, pop_folder(stack)]
    end

    return handle_anchor_fragment(fragment, entries, stack, pending_folder) if fragment.at_css('a[href]')

    [apply_description(fragment, last_entry), pending_folder, stack]
  end

  def open_folder?(stripped)
    stripped.match?(/<dl\b/i)
  end

  def close_folder?(stripped)
    stripped.match?(%r{</dl>}i)
  end

  def stack_with_pending_folder(stack, pending_folder)
    return stack unless pending_folder.present?

    stack + [pending_folder]
  end

  def pop_folder(stack)
    stack.any? ? stack[0...-1] : stack
  end

  def handle_anchor_fragment(fragment, entries, stack, pending_folder)
    anchor = fragment.at_css('a[href]')
    entry = build_entry(anchor, stack)
    entries << entry
    [entry, pending_folder, stack]
  end

  def build_entry(anchor, stack)
    {
      url:         anchor['href'],
      title:       anchor.text.to_s.strip,
      description: nil,
      folders:     stack.dup
    }
  end

  def apply_description(fragment, last_entry)
    return last_entry unless last_entry

    description = fragment.at_css('dd')
    return last_entry unless description

    last_entry[:description] = description.text.to_s.strip.presence
    last_entry
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
