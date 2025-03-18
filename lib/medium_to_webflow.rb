# frozen_string_literal: true

require "thor"
require "httparty"

require_relative "medium_to_webflow/version"
require_relative "medium_to_webflow/config"
require_relative "medium_to_webflow/errors"

require_relative "medium_to_webflow/medium/client"
require_relative "medium_to_webflow/medium/post"
require_relative "medium_to_webflow/sync_service"
require_relative "medium_to_webflow/cli"

module MediumToWebflow
  class << self
    def sync(config)
      apply_configuration!(config)

      SyncService.call(**configuration.to_h)
    end

    def configuration
      @configuration ||= Config.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Config.new
    end

    private

    def apply_configuration!(config)
      %i[medium_username webflow_api_token webflow_collection_id field_mappings].each do |option|
        configuration.send("#{option}=", config[option]) if config[option]
      end

      configuration.validate!
    end
  end
end
