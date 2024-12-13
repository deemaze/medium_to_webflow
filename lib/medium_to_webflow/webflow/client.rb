# frozen_string_literal: true

module MediumToWebflow
  module Webflow
    class Client
      include HTTParty
      base_uri "https://api.webflow.com/v2"
      headers "Accept" => "application/json"
      headers "Content-Type" => "application/json"

      def initialize(api_token:, collection_id:, field_mappings:)
        @api_token = api_token
        @collection_id = collection_id
        @field_mappings = field_mappings
        self.class.headers "Authorization" => "Bearer #{api_token}"
        @logger = MediumToWebflow.configuration.logger
      end

      def upsert_post(medium_post)
        fields = build_fields(medium_post)
        medium_slug_field = @field_mappings.key("slug")
        existing_item = find_item(slug: medium_post.send(medium_slug_field))

        handle_existing_or_create_item(existing_item, fields, medium_post)
      end

      private

      def handle_existing_or_create_item(existing_item, fields, medium_post)
        if existing_item
          handle_existing_item(existing_item, fields, medium_post)
        else
          create_item(fields: fields)
        end
      end

      def handle_existing_item(existing_item, fields, medium_post)
        if MediumToWebflow.configuration.force_update
          @logger.debug "Forcing update of existing item: #{existing_item["id"]}"
          update_item(item_id: existing_item["id"], fields: fields)
        else
          @logger.info "Skipping existing item: #{medium_post.title} (use --force-update to override)"
        end
      end

      def find_item(slug:)
        response = self.class.get("/collections/#{@collection_id}/items/live", query: { slug: slug })

        handle_response(response)["items"]&.first
      end

      def create_item(fields:)
        @logger.debug "Creating Webflow item in collection: #{@collection_id}"
        @logger.debug "Fields: #{fields.inspect}" if MediumToWebflow.configuration.verbose

        response = self.class.post("/collections/#{@collection_id}/items/live", body: {
          fieldData: fields
        }.to_json)
        handle_response(response)
      end

      def update_item(item_id:, fields:)
        @logger.debug "Updating Webflow item: #{item_id} in collection: #{@collection_id}"
        @logger.debug "Fields: #{fields.inspect}" if MediumToWebflow.configuration.verbose

        response = self.class.patch("/collections/#{@collection_id}/items/#{item_id}/live", body: {
          fieldData: fields
        }.to_json)
        handle_response(response)
      end

      def build_fields(medium_post)
        @field_mappings.each_with_object({}) do |(medium_field, webflow_field), fields|
          value = medium_post.public_send(medium_field)
          next if value.nil?

          fields[webflow_field] = process_field_value(medium_field, value)
        end
      end

      def process_field_value(field, value)
        # Handle the image field by converting it to Webflow's expected format { url: "image_url" }
        return { url: value } if field == :image_url

        # Convert DateTime/Time objects to ISO8601 format for Webflow's date fields
        return value.iso8601 if value.respond_to?(:iso8601)

        # Return value as-is for all other field types
        value
      end

      def handle_response(response)
        return response.parsed_response if response.success?

        raise Error, "Webflow API error: #{response.code} - #{response.body}"
      end
    end
  end
end
