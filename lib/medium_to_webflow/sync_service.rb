# frozen_string_literal: true

module MediumToWebflow
  class SyncService
    def self.call(**args)
      new(**args).call
    end

    def initialize(medium_username:, webflow_api_token:, webflow_collection_id:, field_mappings:)
      @medium_username = medium_username
      @webflow_adapter = Webflow::Adapter.new(webflow_api_token, webflow_collection_id)
      @field_mappings = field_mappings
      @logger = MediumToWebflow.configuration.logger
    end

    def call
      @logger.info "Starting Medium to Webflow sync..."
      @logger.debug "Fetching posts from Medium..."

      medium_posts = fetch_medium_posts
      @logger.info "Found #{medium_posts.count} posts to sync"

      sync_medium_posts_to_webflow(medium_posts)

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

    def sync_medium_posts_to_webflow(medium_posts)
      medium_posts.each_with_index do |medium_post, index|
        @logger.debug "Processing post: #{medium_post.title}"
        sync_medium_post_to_webflow(medium_post)
        @logger.info "Successfully synced: #{medium_post.title} (#{index + 1}/#{medium_posts.count})"
      end
    end

    def sync_medium_post_to_webflow(medium_post)
      fields = build_webflow_fields(medium_post)
      medium_slug_field_name = @field_mappings.key("slug")
      existing_item = find_webflow_item_by_slug(medium_post.send(medium_slug_field_name))

      if existing_item
        handle_existing_webflow_item(existing_item, fields, medium_post)
      else
        create_webflow_item(fields)
      end
    end

    def find_webflow_item_by_slug(slug)
      @webflow_adapter.find_by_slug(slug)
    end

    def handle_existing_webflow_item(existing_item, fields, medium_post)
      if MediumToWebflow.configuration.force_update
        @logger.debug "Forcing update of existing item: #{existing_item[:id]}"
        @webflow_adapter.update_item(existing_item[:id], fields)
      else
        @logger.info "Skipping existing item: #{medium_post.title} (use --force-update to override)"
      end
    end

    def create_webflow_item(fields)
      @webflow_adapter.create_item(fields)
    end

    def build_webflow_fields(medium_post)
      @field_mappings.each_with_object({}) do |(medium_field_name, webflow_field_name), fields|
        value = medium_post.public_send(medium_field_name)
        next if value.nil?

        fields[webflow_field_name] = process_field_value(medium_field_name, value)
      end
    end

    def process_field_value(medium_field_name, value)
      # Handle the image field by converting it to Webflow's expected format { url: "image_url" }
      return { url: value } if medium_field_name == :image_url

      # Convert DateTime/Time objects to ISO8601 format for Webflow's date fields
      return value.iso8601 if value.respond_to?(:iso8601)

      # Return value as-is for all other field types
      value
    end
  end
end
