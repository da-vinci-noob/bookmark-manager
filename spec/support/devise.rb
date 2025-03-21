# frozen_string_literal: true

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
end

# Fix for: Failure/Error: sign_in(user) RuntimeError: Could not find a valid mapping for #<User
ActiveSupport.on_load(:action_mailer) do
  Rails.application.reload_routes_unless_loaded
end
