# frozen_string_literal: true

require "nokogiri"

module MediumToWebflow
  module Medium
    class Post
      attr_reader :title, :url, :published_at, :author, :image_url, :category, :guid

      def initialize(attributes)
        @title = attributes[:title]
        @url = attributes[:url]
        @published_at = attributes[:published_at]
        @author = attributes[:author]
        @image_url = attributes[:image_url]
        @category = attributes[:category]
        @guid = attributes[:guid]
      end

      class << self
        def from_rss(item)
          new(
            title: item.title,
            url: item.link,
            published_at: item.pubDate,
            author: item.author || item.dc_creator,
            image_url: extract_image_url(item.content_encoded, item.description),
            category: humanize_category(item.categories&.first&.content),
            guid: extract_guid(item.guid.content)
          )
        end

        private

        def extract_image_url(content_encoded, description)
          # Try to get image from content_encoded first
          if content_encoded
            doc = Nokogiri::HTML(content_encoded)
            img = doc.at_css("img")
            return img["src"] if img && img["src"]
          end

          # Fallback to description
          return nil if description.nil?

          doc = Nokogiri::HTML(description)
          img = doc.at_css("img")
          img["src"] if img && img["src"]
        end

        def extract_guid(guid_content)
          guid_content.split("/").last.downcase
        end

        def humanize_category(category)
          return if category.nil?

          category
            .tr("-", " ")
            .split
            .map(&:capitalize)
            .join(" ")
        end
      end
    end
  end
end
