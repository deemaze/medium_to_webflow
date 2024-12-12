# frozen_string_literal: true

require "nokogiri"

module MediumToWebflow
  module Medium
    class Post
      attr_reader :title, :url, :published_at, :author, :image_url, :category, :slug

      def initialize(title:, url:, published_at:, author:, image_url:, category:, slug:)
        @title = title
        @url = url
        @published_at = published_at
        @author = author
        @image_url = image_url
        @category = category
        @slug = slug
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
            slug: generate_slug(item.guid.content)
          )
        end

        private

        def extract_image_url(content, description)
          # Try to get image from content first
          if content
            doc = Nokogiri::HTML(content)
            img = doc.at_css("img")
            return img["src"] if img && img["src"]
          end

          # Fallback to description
          return nil if description.nil?

          doc = Nokogiri::HTML(description)
          img = doc.at_css("img")
          img["src"] if img && img["src"]
        end

        def generate_slug(guid_content)
          guid_content.split("/").last.downcase
        end

        def humanize_category(category)
          return if category.nil?

          category
            .tr("-", " ")
            .split(" ")
            .map(&:capitalize)
            .join(" ")
        end
      end
    end
  end
end
