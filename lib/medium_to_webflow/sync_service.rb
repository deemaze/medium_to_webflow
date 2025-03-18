# frozen_string_literal: true

require "webflow"

module MediumToWebflow
  class SyncService
    def self.call(**args)
      new(**args).call
    end

    def initialize(medium_username:, webflow_api_token:, webflow_collection_id:, field_mappings:)
      @medium_username = medium_username
      @webflow_client = Webflow::Client.new(webflow_api_token)
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
      posts.each_with_index do |post, index|
        @logger.debug "Processing post: #{post.title}"
        upsert_post(post)
        @logger.info "Successfully synced: #{post.title} (#{index + 1}/#{posts.count})"
      end
    end

    def upsert_post(medium_post)
      fields = build_fields(medium_post)
      medium_slug_field = @field_mappings.key("slug")
      existing_item = find_item_by_slug(medium_post.send(medium_slug_field))

      if existing_item
        handle_existing_item(existing_item, fields, medium_post)
      else
        create_item(fields)
      end
    end

    def find_item_by_slug(slug)
      @webflow_client.list_items(@webflow_collection_id, query_params: { slug: slug }).first
    rescue ::Webflow::Error => e
      @logger.error "Error finding item: #{e.message}"
      nil
    end

    def handle_existing_item(existing_item, fields, medium_post)
      if MediumToWebflow.configuration.force_update
        @logger.debug "Forcing update of existing item: #{existing_item[:id]}"
        @webflow_client.update_item(@webflow_collection_id, existing_item[:id], fields, is_draft: true)
      else
        @logger.info "Skipping existing item: #{medium_post.title} (use --force-update to override)"
      end
    rescue ::Webflow::Error => e
      raise Error, "Failed to update item: #{e.message}"
    end

    def create_item(fields)
      @logger.debug "Creating Webflow item in collection: #{@webflow_collection_id}"
      @logger.debug "Fields: #{fields.inspect}" if MediumToWebflow.configuration.verbose

      @webflow_client.create_item(@webflow_collection_id, fields, is_draft: true)
    rescue ::Webflow::Error => e
      raise Error, "Failed to create item: #{e.message}"
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
  end
end
