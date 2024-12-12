# frozen_string_literal: true

module MediumToWebflow
  class CLI < Thor
    desc "sync", "Sync Medium posts to Webflow collection"
    method_option :medium_username, type: :string, required: true, aliases: "-u"
    method_option :webflow_token, type: :string, required: true
    method_option :webflow_collection_id, type: :string, required: true

    def sync
      puts "Syncing posts for user: #{options[:medium_username]}"
      SyncService.call(
        username: options[:medium_username],
        webflow_token: options[:webflow_token],
        webflow_collection_id: options[:webflow_collection_id]
      )
    end
  end
end
