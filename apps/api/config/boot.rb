ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Load .env file before anything else
begin
  require "dotenv/rails-now"
rescue LoadError
  # Try manual loading if dotenv-rails isn't available
  begin
    require "dotenv"
    env_file = File.expand_path("../.env", __dir__)
    Dotenv.load(env_file) if File.exist?(env_file)
  rescue LoadError
    # dotenv not available, skip
  end
end

require "bootsnap/setup" # Speed up boot time by caching expensive operations.

