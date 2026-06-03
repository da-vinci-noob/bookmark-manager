ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Bootsnap's instruction sequence cache conflicts with coverage collection on Ruby 4 in test.
require "bootsnap/setup" unless ENV["RAILS_ENV"] == "test"
