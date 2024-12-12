# frozen_string_literal: true

module MediumToWebflow
  # SyncService is a class that fetches posts from a Medium RSS feed and upserts them into a Webflow collection.
  class SyncService
    def self.call(username:, webflow_token:, webflow_collection_id:)
      new(
        username: username,
        webflow_token: webflow_token,
        webflow_collection_id: webflow_collection_id
      ).call
    end

    def initialize(username:, webflow_token:, webflow_collection_id:)
      @username = username
      @webflow_token = webflow_token
      @webflow_collection_id = webflow_collection_id
    end

    def call
      medium_client = Medium::Client.new
      webflow_client = Webflow::Client.new(@webflow_token)

      posts = medium_client.fetch_posts(@username)
      posts.each do |post|
        webflow_client.upsert_post(
          collection_id: @webflow_collection_id,
          post: post
        )
        puts "Synced: #{post.title} (#{post.slug})"
      end
    end
  end
end
