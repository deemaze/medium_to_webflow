# frozen_string_literal: true

module MediumToWebflow
  class SyncService
    def self.call(**args)
      new(**args).call
    end

    def initialize(medium_username:, webflow_api_token:, webflow_collection_id:, field_mappings:)
      @medium_username = medium_username
      @webflow_api_token = webflow_api_token
      @webflow_collection_id = webflow_collection_id
      @field_mappings = field_mappings
      @logger = MediumToWebflow.configuration.logger
    end

    def call
      @logger.info "Starting Medium to Webflow sync..."
      @logger.debug "Fetching posts from Medium..."

      medium_posts = fetch_medium_posts
      @logger.info "Found #{medium_posts.count} posts to sync"

      sync_to_webflow(medium_posts)

      @logger.info "Sync completed successfully!"
    rescue StandardError => e
      @logger.error "Sync failed: #{e.message}"
      @logger.debug e.backtrace.join("\n") if MediumToWebflow.configuration.verbose
      raise
    end

    private

    def fetch_medium_posts
      Medium::Client.new(username: @medium_username).fetch_posts
    end

    def sync_to_webflow(posts)
      webflow_client = Webflow::Client.new(
        api_token: @webflow_api_token,
        collection_id: @webflow_collection_id,
        field_mappings: @field_mappings
      )

      posts.each_with_index do |post, index|
        @logger.debug "Processing post: #{post.title}"
        webflow_client.upsert_post(post)
        @logger.info "Successfully synced: #{post.title} (#{index + 1}/#{posts.count})"
      end
    end
  end
end
