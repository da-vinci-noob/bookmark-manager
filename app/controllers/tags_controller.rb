# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :set_tag, only: %i[update destroy]

  def index
    @tags = current_user.tags.includes(:bookmarks)
    respond_to do |format|
      format.html # renders index.html.erb
      format.json do
        render json: @tags.as_json(include: :bookmarks)
      end
    end
  end

  def create
    @tag = Tag.new(tag_params)
    @tag.user = current_user

    if @tag.save
      render json: @tag, status: :created
    else
      render_error(@tag.errors.full_messages)
    end
  end

  def update
    if @tag.update(tag_params)
      render json: @tag
    else
      render_error(@tag.errors.full_messages)
    end
  end

  def destroy
    if @tag.destroy
      head :no_content
    else
      render_error('Failed to delete tag')
    end
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('Tag not found', :not_found)
  end

  def tag_params
    params.expect(tag: %i[name color])
  end
end
