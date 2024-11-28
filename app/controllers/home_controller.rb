# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @bookmarks = current_user.bookmarks
    @tags = current_user.tags
  end
end
