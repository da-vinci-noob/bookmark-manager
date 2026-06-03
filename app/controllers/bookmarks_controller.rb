# frozen_string_literal: true

class BookmarksController < ApplicationController
  before_action :set_bookmark, only: %i[update destroy]

  def index
    @bookmarks = paginate_bookmarks(current_user.bookmarks)
    @tags = current_user.tags

    respond_to do |format|
      format.html
      format.json { render json: build_bookmarks_json }
    end
  end

  def create
    @bookmark = current_user.bookmarks.build(bookmark_params)
    bookmark_create(:created)
  end

  def update
    update_bookmark_attributes
    bookmark_create(:ok)
  end

  def destroy
    return head :no_content if @bookmark.destroy

    render_error('Failed to delete bookmark')
  end

  def fetch_thumbnail
    return render_error('URL is required', :bad_request) if params[:url].blank?

    render json: LinkPreviewService.fetch_thumbnail(params[:url])
  rescue ArgumentError => e
    render_error(e.message, :bad_request)
  rescue LinkPreviewService::PreviewFetchError => e
    render_error(e.message, :service_unavailable)
  rescue LinkPreviewService::PreviewParseError => e
    render_error(e.message, :unprocessable_entity)
  rescue LinkPreviewService::Error => e
    render_error(e.message, :internal_server_error)
  end

  def export
    bookmarks = current_user.bookmarks.includes(:tags).order(created_at: :desc)
    respond_to do |format|
      format.html { send_export BookmarkExportHtmlService.new(bookmarks:).call, '.html', 'text/html' }
      format.csv { send_export BookmarkExportCsvService.new(bookmarks:).call, '.csv', 'text/csv' }
    end
  end

  def import
    file = params[:file]
    return render_error('HTML file is required', :bad_request) if file.blank?

    io = file.respond_to?(:tempfile) ? file.tempfile : file
    render json: { message: 'Import completed', **BookmarkImportHtmlService.new(user: current_user, io:).call }
  rescue BookmarkImportHtmlService::ImportError => e
    render_error(e.message, :unprocessable_entity)
  end

  private

  def send_export(data, ext, type)
    send_data data, filename: "bookmarks-#{Date.current}#{ext}", type: "#{type}; charset=utf-8"
  end

  def set_bookmark
    @bookmark = current_user.bookmarks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('Bookmark not found', :not_found)
  end

  def update_bookmark_attributes
    url = bookmark_params[:url]
    thumbnail = url.present? && url != @bookmark.url ? fetch_thumbnail_safe(url) : {}
    @bookmark.assign_attributes(bookmark_params.merge(thumbnail))
  end

  def fetch_thumbnail_safe(url)
    LinkPreviewService.fetch_thumbnail(url)
  rescue StandardError
    {}
  end

  def bookmark_create(status)
    return render(json: @bookmark, include: :tags, status:) if @bookmark.save

    render_error(@bookmark.errors.full_messages.join(', '))
  end

  def paginate_bookmarks(scope)
    @page = [params[:page].to_i, 1].max
    @total_count = scope.count
    @per_page = [params[:per_page].to_i, 12].max
    scope.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def build_bookmarks_json
    {
      bookmarks:  @bookmarks.as_json(include: :tags),
      tags:       current_user.tags.as_json,
      pagination: {
        total_count:  @total_count,
        total_pages:  (@total_count.to_f / @per_page).ceil,
        current_page: @page,
        per_page:     @per_page
      }
    }
  end

  def bookmark_params
    params.expect(bookmark: [:url, :title, :description, :thumbnail_url, :starred, { tag_ids: [] }])
  end
end
