# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  protect_from_forgery with: :exception

  private

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status:
  end
end
