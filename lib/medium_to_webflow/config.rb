# frozen_string_literal: true

require "logger"

module MediumToWebflow
  class Config
    REQUIRED_WEBFLOW_FIELDS = %w[name slug].freeze
    REQUIRED_SETTINGS = %i[medium_username webflow_api_token webflow_collection_id].freeze

    attr_accessor :medium_username, :webflow_api_token, :webflow_collection_id, :field_mappings,
                  :logger, :force_update
    attr_reader :verbose

    def initialize
      @logger = Logger.new($stdout)
      @logger.level = Logger::INFO
      @verbose = false
      @force_update = false
    end

    def verbose=(value)
      @verbose = value
      @logger.level = value ? Logger::DEBUG : Logger::INFO
    end

    def validate!
      validate_required_settings!
      validate_required_field_mappings!
    end

    def to_h
      {
        medium_username: medium_username,
        webflow_api_token: webflow_api_token,
        webflow_collection_id: webflow_collection_id,
        field_mappings: field_mappings
      }
    end

    private

    def validate_required_settings!
      missing_settings = REQUIRED_SETTINGS.select { |setting| send(setting).nil? }
      return if missing_settings.empty?

      raise ConfigError, "Missing required configuration: #{missing_settings.join(", ")}"
    end

    def validate_required_field_mappings!
      unless field_mappings.is_a?(Hash)
        raise ConfigError, "field_mappings must be a Hash mapping Medium attributes to Webflow fields"
      end

      missing_fields = REQUIRED_WEBFLOW_FIELDS.reject { |field| field_mappings.values.include?(field) }
      return if missing_fields.empty?

      raise ConfigError,
            "Required Webflow fields must be mapped to: #{missing_fields.join(", ")}. " \
            "Ensure you map Medium attributes to these required Webflow fields."
    end
  end
end
