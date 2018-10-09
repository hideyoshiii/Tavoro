require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tavore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    RSpotify.authenticate("9bc9eb4919204e978d800ae0cf764290", "9584a8e2f7e64c98a77267efa761d6e7")

    Tmdb::Api.key("422b1abe30d312f0bbf90aa299e645b3")
	Tmdb::Api.language("en")

  end
end
