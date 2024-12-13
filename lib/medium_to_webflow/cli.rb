# frozen_string_literal: true

module MediumToWebflow
  class CLI < Thor
    class_option :config,
                 type: :string,
                 desc: "Path to a Ruby config file that sets up Medium and Webflow credentials",
                 aliases: "-c"

    desc "sync", "Sync Medium posts to Webflow"
    method_option :medium_username,
                  type: :string,
                  aliases: "-u",
                  desc: "Medium username (without the @ symbol)"
    method_option :webflow_api_token,
                  type: :string,
                  aliases: "-t",
                  desc: "Webflow API token with CMS permissions"
    method_option :webflow_collection_id,
                  type: :string,
                  aliases: "-l",
                  desc: "The ID of the Webflow collection where posts will be imported"
    method_option :field_mappings,
                  type: :hash,
                  aliases: "-m",
                  desc: "Map Medium post fields to Webflow collection fields (e.g. title:name content:post-content)"
    method_option :verbose,
                  type: :boolean,
                  aliases: "-v",
                  desc: "Enable verbose logging"
    method_option :force_update,
                  type: :boolean,
                  aliases: "-f",
                  desc: "Force update existing posts (default: false)"

    def sync
      load_config if options[:config]

      MediumToWebflow.configure do |config|
        config.verbose = options[:verbose]
        config.force_update = options[:force_update]
      end

      MediumToWebflow.sync(options)
    rescue Error => e
      error "Failed to sync: #{e.message}"
      exit 1
    end

    desc "init", "Generate a sample config file"
    method_option :path,
                  type: :string,
                  default: "config/medium_to_webflow.rb",
                  desc: "Path to generate the config file",
                  aliases: "-p"
    def init
      create_file(options[:path], config_template)
    end

    private

    def load_config
      require File.expand_path(options[:config])
    rescue LoadError => e
      error "Could not load config file: #{e.message}"
      exit 1
    end

    def create_file(path, content)
      if File.exist?(path)
        error "File already exists: #{path}"
        exit 1
      end

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)

      say "Created config file at #{path}", :green
    end

    def error(message)
      say "Error: #{message}", :red
    end

    def config_template
      <<~RUBY
        # frozen_string_literal: true

        MediumToWebflow.configure do |config|
          # Required settings
          config.medium_username = ENV.fetch("MEDIUM_USERNAME", nil)
          config.webflow_api_token = ENV.fetch("WEBFLOW_API_TOKEN", nil)
          config.webflow_collection_id = ENV.fetch("WEBFLOW_COLLECTION_ID", nil)

          # Field mappings from Medium post attributes to Webflow field names
          # Available Medium post attributes:
          #   - title: The post title
          #   - url: The Medium post URL
          #   - published_at: Publication date
          #   - author: Post author
          #   - image_url: Featured image URL
          #   - category: Post category
          #   - guid: The post's unique identifier from Medium
          #
          # Required Webflow fields:
          #   - name: The item name in Webflow
          #   - slug: The URL slug in Webflow
          #
          # Example mapping (adjust according to your Webflow collection structure):
          config.field_mappings = {
            # Map Medium attributes to your Webflow collection fields
            title: "name",          # Required: maps to Webflow's name field
            guid: "slug",           # Required: maps to Webflow's slug field
            url: "source-url",      # Optional: maps to a custom field in your collection
            published_at: "date",   # Optional: maps to a date field
            author: "author",       # Optional: maps to an author field
            image_url: "image",     # Optional: maps to an image field (will be converted to { url: value })
            category: "category"    # Optional: maps to a category field
          }
        end
      RUBY
    end
  end
end
