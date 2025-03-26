# frozen_string_literal: true

require "webflow"

module MediumToWebflow
  module Webflow
    class Adapter
      def initialize(api_token, collection_id)
        @client = ::Webflow::Client.new(api_token)
        @collection_id = collection_id
        @logger = MediumToWebflow.configuration.logger
      end

      def find_by_slug(slug)
        @client.list_items(@collection_id, query_params: { slug: slug }).first
      rescue ::Webflow::Error => e
        handle_error("list_items", e)
        nil
      end

      def create_item(fields)
        @logger.debug "Creating Webflow item in collection: #{@collection_id}"
        @logger.debug "Fields: #{fields.inspect}" if MediumToWebflow.configuration.verbose

        @client.create_item(@collection_id, fields, is_draft: true)
      rescue ::Webflow::Error => e
        handle_error("create_item", e)
      end

      def update_item(item_id, fields)
        @logger.debug "Updating Webflow item: #{item_id} in collection: #{@collection_id}"
        @logger.debug "Fields: #{fields.inspect}" if MediumToWebflow.configuration.verbose

        @client.update_item(@collection_id, item_id, fields, is_draft: true)
      rescue ::Webflow::Error => e
        handle_error("update_item", e)
      end

      private

      def handle_error(operation, error)
        error_message = "Webflow #{operation} operation failed: #{error.message}"
        @logger.error error_message
        raise MediumToWebflow::Error, error_message
      end
    end
  end
end
