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
    end

    def call
      medium_posts = fetch_medium_posts
      sync_to_webflow(medium_posts)
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

      posts.each do |post|
        webflow_client.upsert_post(post)
      end
    end
  end
end
