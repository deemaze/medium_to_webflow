# frozen_string_literal: true

require_relative "lib/medium_to_webflow/version"

Gem::Specification.new do |spec|
  spec.name = "medium_to_webflow"
  spec.version = MediumToWebflow::VERSION
  spec.authors = ["Paulo Santos"]
  spec.email = ["paulo.santos@deemaze.com"]

  spec.summary = "Sync Medium posts to Webflow CMS collections"
  spec.description = "A library and CLI tool to fetch posts from Medium and sync them to Webflow CMS collections"
  spec.homepage = "https://github.com/deemaze/medium_to_webflow"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{bin,lib}/**/*") + %w[LICENSE.txt README.md]
  spec.executables = ["medium_to_webflow"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.22.0"
  spec.add_dependency "nokogiri", "~> 1.17"
  spec.add_dependency "rss", "~> 0.3.1"
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "webflow-rb", "~> 1.1"
end
