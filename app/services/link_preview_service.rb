# frozen_string_literal: true

class LinkPreviewService
  class Error < StandardError; end
  class PreviewFetchError < Error; end
  class PreviewParseError < Error; end

  LINK_PREVIEW_API_KEY = ENV.fetch('LINK_PREVIEW_API_KEY')

  def self.fetch_thumbnail(url)
    new.fetch_thumbnail(url)
  end

  def fetch_thumbnail(url)
    validate_url(url)
    response = link_preview_request(url)
    handle_preview_response(response)
  rescue StandardError => e
    handle_preview_error(e)
  end

  private

  def validate_url(url)
    uri = URI.parse(url)
    raise ArgumentError, 'Invalid URL' unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    raise ArgumentError, 'Invalid URL format'
  end

  def handle_preview_response(response)
    raise PreviewFetchError, "Failed to fetch preview: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    { title: data['title'], description: data['description'], thumbnail_url: data['image'] }
  rescue JSON::ParserError
    raise PreviewParseError, 'Failed to parse preview data'
  end

  def handle_preview_error(error)
    case error
    when ArgumentError, PreviewFetchError, PreviewParseError
      raise error
    else
      raise Error, "An error occurred: #{error.message}"
    end
  end

  def link_preview_request(url)
    preview_uri = URI("https://api.linkpreview.net/?key=#{LINK_PREVIEW_API_KEY}&q=#{URI.encode_www_form_component(url)}")
    http = Net::HTTP.new(preview_uri.host, preview_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new(preview_uri)
    request['Accept'] = 'application/json'

    http.request(request)
  end
end
