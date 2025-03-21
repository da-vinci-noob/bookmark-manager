# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookmarks' do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe '#index' do
    before do
      create_list(:bookmark, 3, user: user)
      create_list(:tag, 2, user: user)
    end

    it 'returns a successful response with HTML format' do
      get bookmarks_path
      data = response.parsed_body.css('#bookmarks[data-bookmarks]').first
      bookmarks = JSON.parse(data['data-bookmarks'])
      tags = JSON.parse(data['data-tags'])
      expect([bookmarks.length, tags.length]).to eq([3, 2])
    end

    it 'returns a successful response with JSON format' do
      get bookmarks_path, as: :json
      expect(response).to have_http_status(:ok)

      json_response = response.parsed_body
      expect([json_response[:bookmarks].length, json_response[:tags].length]).to eq([3, 2])
    end
  end

  describe '#create' do
    let(:tag) { create(:tag, user: user) }
    let(:valid_attributes) do
      {
        bookmark: {
          url:         'https://example.com',
          title:       'Example Website',
          description: 'An example website',
          tag_ids:     [tag.id]
        }
      }
    end
    let(:invalid_attributes) { { bookmark: { url: 'invalid-url', title: '', tag_ids: [] } } }

    context 'with valid parameters' do
      it 'creates a new bookmark' do
        expect do
          post bookmarks_path, params: valid_attributes, headers: headers
        end.to change(Bookmark, :count).by(1)
      end

      it 'returns a JSON response with the new bookmark' do
        post bookmarks_path, params: valid_attributes, headers: headers
        expect(response).to have_http_status(:created)

        json_response = response.parsed_body.values_at('url', 'title', 'description', 'tags')
        expected_response = valid_attributes[:bookmark].except(:tag_ids).values
        expect(json_response).to eq(expected_response << [JSON.parse(tag.to_json)])
      end

      it 'associates the bookmark with the current user' do
        post bookmarks_path, params: valid_attributes, headers: headers
        expect(Bookmark.last.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new bookmark' do
        expect do
          post bookmarks_path, params: invalid_attributes, headers: headers
        end.not_to change(Bookmark, :count)
      end

      it 'returns a JSON response with errors' do
        post bookmarks_path, params: invalid_attributes, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = response.parsed_body
        expect(json_response).to have_key('error')
      end
    end
  end

  describe 'PUT /update' do
    let(:bookmark) { create(:bookmark, user: user) }
    let(:tag) { create(:tag, user: user) }
    let(:other_user_bookmark) { create(:bookmark, user: create(:user)) }
    let(:valid_attributes) { { bookmark: { title: 'Updated Title', description: 'Updated description', tag_ids: [tag.id] } } }
    let(:url_update_attributes) { { bookmark: { url: 'https://updated-example.com', title: 'Updated with URL' } } }

    context 'with valid parameters' do
      it 'updates the requested bookmark' do
        put bookmark_path(bookmark), params: valid_attributes, headers: headers
        bookmark.reload

        expect(bookmark.title).to eq(valid_attributes[:bookmark][:title])
        expect(bookmark.description).to eq(valid_attributes[:bookmark][:description])
      end

      it 'returns a JSON response with the updated bookmark' do
        put bookmark_path(bookmark), params: valid_attributes, headers: headers
        expect(response).to have_http_status(:ok)

        json_response = response.parsed_body
        expect(json_response['title']).to eq(valid_attributes[:bookmark][:title])
        expect(json_response['description']).to eq(valid_attributes[:bookmark][:description])
      end

      it 'updates bookmark tags' do
        put bookmark_path(bookmark), params: valid_attributes, headers: headers
        bookmark.reload

        expect(bookmark.tags).to include(tag)
      end
    end

    context 'when updating URL' do
      before do
        allow(LinkPreviewService).to receive(:fetch_thumbnail).and_return(
          {
            title:         'Service Title',
            description:   'Service Description',
            thumbnail_url: 'https://example.com/image.jpg'
          }
        )
      end

      it 'fetches new thumbnail data when URL changes' do
        put bookmark_path(bookmark), params: url_update_attributes, headers: headers
        bookmark.reload

        expect(bookmark.url).to eq(url_update_attributes[:bookmark][:url])
        expect(bookmark.thumbnail_url).to eq('https://example.com/image.jpg')
        expect(LinkPreviewService).to have_received(:fetch_thumbnail)
      end

      it 'handles errors from LinkPreviewService gracefully' do
        allow(LinkPreviewService).to receive(:fetch_thumbnail).and_raise(StandardError)

        put bookmark_path(bookmark), params: url_update_attributes, headers: headers
        expect(response).to have_http_status(:ok)

        bookmark.reload
        expect(bookmark.url).to eq(url_update_attributes[:bookmark][:url])
      end
    end

    context 'with invalid parameters' do
      it 'returns a JSON response with errors' do
        invalid_attributes = { bookmark: { title: '', url: 'invalid-url' } }

        put bookmark_path(bookmark), params: invalid_attributes, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = response.parsed_body
        expect(json_response).to have_key('error')
      end
    end

    context 'when bookmark does not belong to user' do
      it 'returns 404 not found' do
        put bookmark_path(other_user_bookmark), params: valid_attributes, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:bookmark) { create(:bookmark, user: user) }

    it 'destroys the requested bookmark' do
      bookmark.reload
      expect do
        delete bookmark_path(bookmark), headers: headers
      end.to change(Bookmark, :count).by(-1)
    end

    it 'returns a no content response' do
      delete bookmark_path(bookmark), headers: headers
      expect(response).to have_http_status(:no_content)
    end

    context 'when bookmark does not belong to user' do
      let(:other_user_bookmark) { create(:bookmark, user: create(:user)) }

      it 'returns 404 not found' do
        delete bookmark_path(other_user_bookmark), headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'does errors while destroying the bookmark' do
        allow_any_instance_of(Bookmark).to receive(:destroy).and_return(false)
        delete bookmark_path(bookmark), headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /fetch_thumbnail' do
    let(:mock_headers) do
      {
        Accept:            'application/json',
        'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        Host:              'api.linkpreview.net',
        'User-Agent':      'Ruby'
      }
    end

    let(:mock_url) do
      "https://api.linkpreview.net/?key=asdf&q=#{URI.encode_www_form_component('https://example.com')}"
    end

    before do
      stub_const('LinkPreviewService::LINK_PREVIEW_API_KEY', 'asdf')
    end

    context 'with valid URL' do
      it 'returns thumbnail data' do
        mock_response = { title: 'Example Title', description: 'Example Description', image: 'https://example.com/image.jpg' }

        stub_request(:get, mock_url).with(headers: mock_headers).to_return(status: 200, body: mock_response.to_json)

        get fetch_thumbnail_bookmarks_path, params: { url: 'https://example.com' }, headers: headers
        json_response = response.parsed_body
        expect(json_response['title']).to eq('Example Title')
        expect(json_response['description']).to eq('Example Description')
        expect(json_response['thumbnail_url']).to eq('https://example.com/image.jpg')
      end
    end

    context 'with missing URL' do
      it 'returns bad request error' do
        get fetch_thumbnail_bookmarks_path, params: { url: '' }, headers: headers
        expect(response).to have_http_status(:bad_request)

        json_response = response.parsed_body
        expect(json_response).to have_key('error')
      end
    end

    context 'with invalid URL without https/http' do
      it 'returns Invalid URL' do
        allow(LinkPreviewService).to receive(:fetch_thumbnail).and_raise(ArgumentError.new('Invalid URL'))
        get fetch_thumbnail_bookmarks_path, params: { url: 'invalid-url' }, headers: headers
        expect(response).to have_http_status(:bad_request)

        json_response = response.parsed_body
        expect(json_response['error']).to eq('Invalid URL')
      end
    end

    context 'when LinkPreviewService raises errors' do
      it 'handles PreviewFetchError' do
        stub_request(:get, mock_url).with(headers: mock_headers).to_return(status: 522, body: 'wewe')

        get fetch_thumbnail_bookmarks_path, params: { url: 'https://example.com' }, headers: headers
        expect(response).to have_http_status(:service_unavailable)

        json_response = response.parsed_body
        expect(json_response['error']).to eq('Failed to fetch preview: wewe')
      end

      it 'handles PreviewParseError' do
        stub_request(:get, mock_url).with(headers: mock_headers).to_return(status: 200, body: 'wewe')

        get fetch_thumbnail_bookmarks_path, params: { url: 'https://example.com' }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = response.parsed_body
        expect(json_response['error']).to eq('Failed to parse preview data')
      end

      it 'handles generic Error' do
        # allow(LinkPreviewService).to receive(:fetch_thumbnail).and_raise(LinkPreviewService::Error.new('An error occurred: Generic error'))
        #
        stub_request(:get, mock_url).with(headers: mock_headers).to_return(status: 200, body: ['X'])

        get fetch_thumbnail_bookmarks_path, params: { url: 'https://example.com' }, headers: headers
        expect(response).to have_http_status(:internal_server_error)

        json_response = response.parsed_body
        expect(json_response['error']).to eq('An error occurred: no implicit conversion of Array into String')
      end
    end

    context 'when LINK_PREVIEW_API_KEY is missing' do
      it 'returns an empty response' do
        allow(LinkPreviewService).to receive(:fetch_thumbnail).and_return({})
        get fetch_thumbnail_bookmarks_path, params: { url: 'https://example.com' }, headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq({})
      end
    end
  end
end
