# frozen_string_literal: true

require 'nokogiri'

class BookmarkHtmlParser
  def initialize(html)
    @html = html
  end

  def parse
    entries = []
    stack = []
    pending = nil
    last_entry = nil

    @html.each_line do |line|
      last_entry, pending, stack = process_line(line, entries, last_entry, pending, stack)
    end

    entries
  end

  private

  def process_line(line, entries, last_entry, pending, stack)
    stripped = line.strip
    return [last_entry, pending, stack] if stripped.empty?

    fragment = Nokogiri::HTML.fragment(stripped)
    heading = fragment.at_css('h3')
    return [last_entry, sanitize_folder(heading.text), stack] if heading
    return [last_entry, nil, push_folder(stack, pending)] if open_folder?(stripped)
    return [last_entry, pending, pop_folder(stack)] if close_folder?(stripped)
    return anchor_fragment(fragment, entries, stack, pending) if fragment.at_css('a[href]')

    [apply_description(fragment, last_entry), pending, stack]
  end

  def open_folder?(stripped)
    stripped.match?(/<dl\b/i)
  end

  def close_folder?(stripped)
    stripped.match?(%r{</dl>}i)
  end

  def push_folder(stack, pending)
    pending.blank? ? stack : stack + [pending]
  end

  def pop_folder(stack)
    stack.any? ? stack[0...-1] : stack
  end

  def anchor_fragment(fragment, entries, stack, pending)
    anchor = fragment.at_css('a[href]')
    entry = { url: anchor['href'], title: anchor.text.to_s.strip, description: nil, folders: stack.dup }
    entries << entry
    [entry, pending, stack]
  end

  def apply_description(fragment, last_entry)
    return last_entry unless last_entry

    desc = fragment.at_css('dd')
    last_entry[:description] = desc.text.to_s.strip.presence if desc
    last_entry
  end

  def sanitize_folder(value)
    value.to_s.strip[0, 255]
  end
end
