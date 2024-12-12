# frozen_string_literal: true

module MediumToWebflow
  module Webflow
    # Webflow::Client is a class that interacts with the Webflow API to upsert posts into a collection.
    class Client
      include HTTParty
      base_uri "https://api.webflow.com/v2"
      headers "Accept" => "application/json"
      headers "Content-Type" => "application/json"

      def initialize(token)
        @token = token
        self.class.headers "Authorization" => "Bearer #{token}"
      end

      def upsert_post(collection_id:, post:)
        existing_item = find_item(collection_id: collection_id, slug: post.slug)

        fields = build_fields(post)

        if existing_item
          update_item(collection_id: collection_id, item_id: existing_item["id"], fields: fields)
        else
          create_item(collection_id: collection_id, fields: fields)
        end
      end

      private

      def find_item(collection_id:, slug:)
        response = self.class.get("/collections/#{collection_id}/items/live", query: { slug: slug })

        handle_response(response)["items"]&.first
      end

      def create_item(collection_id:, fields:)
        response = self.class.post("/collections/#{collection_id}/items/live", body: {
          fieldData: fields
        }.to_json)
        handle_response(response)
      end

      def update_item(collection_id:, item_id:, fields:)
        response = self.class.patch("/collections/#{collection_id}/items/#{item_id}/live", body: {
          fieldData: fields
        }.to_json)
        handle_response(response)
      end

      def build_fields(post)
        {
          "medium-id": post.slug,
          name: post.title,
          slug: post.slug,
          "slug-url": post.url,
          "published-at": post.published_at.iso8601,
          writer: post.author,
          image: { url: post.image_url },
          segment: post.category
        }
      end

      def handle_response(response)
        return response.parsed_response if response.success?

        raise Error, "Webflow API error: #{response.code} - #{response.body}"
      end
    end
  end
end
