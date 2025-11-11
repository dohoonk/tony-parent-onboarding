ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Load .env file before anything else
begin
  require "dotenv"
  env_file = File.expand_path("../.env", __dir__)
  Dotenv.load(env_file) if File.exist?(env_file)
rescue LoadError
  # dotenv-rails not available, skip
end

require "bootsnap/setup" # Speed up boot time by caching expensive operations.

