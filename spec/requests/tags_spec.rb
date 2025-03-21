# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tags' do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe '#index' do
    before do
      create_list(:tag, 2, user: user)
    end

    it 'returns a successful response with HTML format' do
      get tags_path
      data = response.parsed_body.css('#tags[data-tags]').first
      tags = JSON.parse(data['data-tags'])
      expect(response).to have_http_status(:ok)
      expect(tags.length).to eq(2)
    end

    it 'returns a successful response with JSON format' do
      get tags_path, as: :json
      expect(response).to have_http_status(:ok)

      json_response = response.parsed_body
      expect(json_response.count).to eq(2)
    end
  end

  describe '#create' do
    let(:tag) { create(:tag, user: user) }
    let(:valid_attributes) { { tag: { name: 'New Tag' } } }
    let(:invalid_attributes) { { tag: { name: '' } } }

    context 'with valid parameters' do
      it 'creates a new tag' do
        expect do
          post tags_path, params: valid_attributes, headers: headers
        end.to change(Tag, :count).by(1)
      end

      it 'returns a JSON response with the new tag' do
        post tags_path, params: valid_attributes, headers: headers
        expect(response).to have_http_status(:created)

        json_response = response.parsed_body
        expect(json_response['name']).to eq(valid_attributes[:tag][:name])
      end

      it 'associates the tag with the current user' do
        post tags_path, params: valid_attributes, headers: headers
        expect(tag.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new tag' do
        expect do
          post tags_path, params: invalid_attributes, headers: headers
        end.not_to change(Tag, :count)
      end

      it 'returns a JSON response with errors' do
        post tags_path, params: invalid_attributes, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = response.parsed_body
        expect(json_response).to have_key('error')
      end
    end
  end

  describe 'PUT /update' do
    let(:tag) { create(:tag, user: user) }
    let(:valid_attributes) { { tag: { name: 'Updated Name' } } }
    let(:invalid_attributes) { { tag: { name: '' } } }

    context 'with valid parameters' do
      it 'updates the requested tag' do
        put tag_path(tag), params: valid_attributes, headers: headers
        tag.reload

        expect(tag.name).to eq(valid_attributes[:tag][:name])
      end

      it 'returns a JSON response with the updated tag' do
        put tag_path(tag), params: valid_attributes, headers: headers
        expect(response).to have_http_status(:ok)

        json_response = response.parsed_body
        expect(json_response['name']).to eq(valid_attributes[:tag][:name])
      end
    end

    context 'with invalid parameters' do
      it 'returns a JSON response with errors' do
        put tag_path(tag), params: invalid_attributes, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = response.parsed_body
        expect(json_response).to have_key('error')
      end
    end

    context 'when tag does not belong to user' do
      let(:other_user_tag) { create(:tag, user: create(:user)) }

      it 'returns 404 not found' do
        put tag_path(other_user_tag), params: valid_attributes, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:tag) { create(:tag, user: user) }

    it 'destroys the requested tag' do
      tag.reload
      expect do
        delete tag_path(tag), headers: headers
      end.to change(Tag, :count).by(-1)
    end

    it 'returns a no content response' do
      delete tag_path(tag), headers: headers
      expect(response).to have_http_status(:no_content)
    end

    context 'when tag does not belong to user' do
      let(:other_user_tag) { create(:tag, user: create(:user)) }

      it 'returns 404 not found' do
        delete tag_path(other_user_tag), headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'does errors while destroying the tag' do
        allow_any_instance_of(Tag).to receive(:destroy).and_return(false)
        delete tag_path(tag), headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
