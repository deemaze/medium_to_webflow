# frozen_string_literal: true

require "httparty"
require "rss"

module MediumToWebflow
  module Medium
    # Medium::Client is a class that fetches posts from a Medium RSS feed, and returns them as a list of Post objects.
    class Client
      include HTTParty
      base_uri "https://medium.com/feed"

      def fetch_posts(username)
        response = self.class.get("/#{username}")
        raise Error, "Failed to fetch Medium posts: #{response.code}" unless response.success?

        parse_feed(response.body)
      end

      private

      def parse_feed(xml)
        feed = RSS::Parser.parse(xml)
        feed.items.map { |item| Post.from_rss(item) }
      rescue RSS::Error => e
        raise Error, "Failed to parse Medium RSS feed: #{e.message}"
      end
    end
  end
end
