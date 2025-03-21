# frozen_string_literal: true

class BookmarksController < ApplicationController
  before_action :set_bookmark, only: %i[update destroy]

  def index
    @bookmarks = current_user.bookmarks.includes(:tags)
    @tags = current_user.tags

    respond_to do |format|
      format.html # renders index.html.erb
      format.json do
        render json: { bookmarks: @bookmarks.as_json(include: :tags), tags: @tags.as_json }
      end
    end
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.user = current_user
    bookmark_create(:created)
  end

  def update
    update_bookmark_attributes
    bookmark_create(:ok)
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
    return render_error('URL is required', :bad_request) if url.blank?

    thumbnail_data = LinkPreviewService.fetch_thumbnail(url)
    render json: thumbnail_data
  rescue ArgumentError => e
    render_error(e.message, :bad_request)
  rescue LinkPreviewService::PreviewFetchError => e
    render_error(e.message, :service_unavailable)
  rescue LinkPreviewService::PreviewParseError => e
    render_error(e.message, :unprocessable_entity)
  rescue LinkPreviewService::Error => e
    render_error(e.message, :internal_server_error)
  end

  private

  def set_bookmark
    @bookmark = current_user.bookmarks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('Bookmark not found', :not_found)
  end

  def update_bookmark_attributes
    if url_changed?
      update_with_thumbnail
    else
      @bookmark.assign_attributes(bookmark_params)
    end
  end

  def url_changed?
    bookmark_params[:url].present? && bookmark_params[:url] != @bookmark.url
  end

  def update_with_thumbnail
    thumbnail_data = LinkPreviewService.fetch_thumbnail(bookmark_params[:url])
    @bookmark.assign_attributes(bookmark_params.merge(thumbnail_data))
  rescue StandardError
    @bookmark.assign_attributes(bookmark_params)
  end

  def bookmark_create(status)
    if @bookmark.save
      render(json: @bookmark, include: :tags, status:)
    else
      render_error(@bookmark.errors.full_messages.join(', '))
    end
  end

  def bookmark_params
    params.expect(bookmark: [:url, :title, :description, :thumbnail_url, { tag_ids: [] }])
  end
end
