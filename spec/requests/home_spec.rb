# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home' do
  describe '#index' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'returns a successful response without data' do
      get root_path
      data = response.parsed_body.css('#home[data-bookmarks]').first

      expect([JSON.parse(data['data-bookmarks']).count, JSON.parse(data['data-tags']).count]).to eq([0, 0])
    end

    it 'returns a successful response with data' do
      create_list(:bookmark, 3, user: user)
      create_list(:tag, 2, user: user)
      get root_path
      data = response.parsed_body.css('#home[data-bookmarks]').first

      expect([JSON.parse(data['data-bookmarks']).count, JSON.parse(data['data-tags']).count]).to eq([3, 2])
    end
  end
end
