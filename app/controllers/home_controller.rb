# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @bookmarks = Bookmark.all
    @tags = Tag.all
  end
end
