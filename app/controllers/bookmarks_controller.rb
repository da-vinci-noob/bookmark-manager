# frozen_string_literal: true

require 'net/http'
require 'json'

class BookmarksController < ApplicationController
  LINK_PREVIEW_API_KEY = ENV.fetch('LINK_PREVIEW_API_KEY') { raise 'LINK_PREVIEW_API_KEY is required' }

  before_action :set_bookmark, only: %i[show update destroy]

  def index
    @bookmarks = Bookmark.includes(:tags)
    @tags = Tag.all

    respond_to do |format|
      format.html # renders index.html.erb
      format.json do
        render json: { bookmarks: @bookmarks.as_json(include: :tags), tags: @tags.as_json }
      end
    end
  end

  def show
    render json: @bookmark, include: :tags
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)

    if @bookmark.save
      render json: @bookmark, include: :tags, status: :created
    else
      render_error(@bookmark.errors.full_messages.join(', '))
    end
  end

  def update
    if bookmark_params[:url].present? && bookmark_params[:url] != @bookmark.url
      thumbnail_data = fetch_thumbnail(bookmark_params[:url])
      if thumbnail_data
        @bookmark.assign_attributes(bookmark_params.merge(thumbnail_data))
      else
        @bookmark.assign_attributes(bookmark_params)
      end
    else
      @bookmark.assign_attributes(bookmark_params)
    end

    if @bookmark.save
      render json: @bookmark, include: :tags
    else
      render_error(@bookmark.errors.full_messages)
    end
  end

  def destroy
    if @bookmark.destroy
      head :no_content
    else
      render_error('Failed to delete bookmark')
    end
  end

  def fetch_thumbnail
    url = params[:url]
    Rails.logger.info "Received URL: #{url.inspect}"
    return render_error('URL is required', :bad_request) if url.blank?

    begin
      uri = URI.parse(url)
      return render_error('Invalid URL', :bad_request) unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      # Build LinkPreview API URL
      preview_uri = URI("https://api.linkpreview.net/?key=#{LINK_PREVIEW_API_KEY}&q=#{URI.encode_www_form_component(url)}")

      # Create HTTP client with SSL
      http = Net::HTTP.new(preview_uri.host, preview_uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      # Create request
      request = Net::HTTP::Get.new(preview_uri)
      request['Accept'] = 'application/json'

      Rails.logger.info "Making request to LinkPreview API with URL: #{url}"

      # Make request
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        Rails.logger.info "LinkPreview API response: #{data.inspect}"

        render json: { title: data['title'], description: data['description'], thumbnail_url: data['image'] }
      else
        Rails.logger.error "LinkPreview API error: Status #{response.code}, Body: #{response.body}"
        render_error("Failed to fetch preview: #{response.body}", :service_unavailable)
      end
    rescue URI::InvalidURIError => e
      Rails.logger.error "Invalid URL format: #{e.message}"
      render_error('Invalid URL format', :bad_request)
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse API response: #{e.message}"
      render_error('Failed to parse preview data', :service_unavailable)
    rescue StandardError => e
      Rails.logger.error "Unexpected error: #{e.class} - #{e.message}"
      render_error("An error occurred: #{e.message}", :internal_server_error)
    end
  end

  private

  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('Bookmark not found', :not_found)
  end

  def bookmark_params
    params.require(:bookmark).permit(:url, :title, :description, :thumbnail_url, tag_ids: [])
  end
end
