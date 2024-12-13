# Medium to Webflow

Sync your Medium posts to a Webflow CMS collection.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'medium_to_webflow'
```

Or install it yourself as:

```bash
$ gem install medium_to_webflow
```

## Usage

### As a Ruby Library

You can configure the gem using a configuration block:

```ruby
MediumToWebflow.configure do |config|
  # Required settings
  config.medium_username = "your-medium-username"
  config.webflow_api_token = "your-webflow-api-token"
  config.webflow_collection_id = "your-collection-id"

  # Customize field mappings (optional)
  config.field_mappings = {
    # Required mappings (Webflow needs these fields)
    title: "name",           # Maps Medium title to Webflow's name field
    guid: "slug",           # Maps Medium guid to Webflow's slug field

    # Optional mappings (customize based on your Webflow collection fields)
    url: "medium-url",      # Maps Medium URL to a custom Webflow field
    published_at: "published-at",
    author: "author",
    image_url: "image",     # Will be converted to { url: image_url }
    category: "category"
  }
end

# Then sync your posts
MediumToWebflow.sync
```

Or pass options directly to the sync method:

```ruby
MediumToWebflow.sync(
  medium_username: "your-medium-username",
  webflow_api_token: "your-webflow-api-token",
  webflow_collection_id: "your-collection-id"
)
```

### Field Mappings

The gem maps Medium post attributes to Webflow collection fields. You can customize these mappings to match your Webflow collection structure:

Available Medium post attributes:

- `title`: The post title
- `url`: The Medium post URL
- `published_at`: Publication date
- `author`: Post author
- `image_url`: Featured image URL
- `category`: Post category
- `guid`: The Medium post guid

Required Webflow fields:

- `name`: The item name (usually mapped from Medium's title)
- `slug`: The URL slug (usually mapped from Medium's slug)

Example custom mapping:

```ruby
config.field_mappings = {
  # Map Medium title to a custom Webflow field
  title: "article-title",
  # Map Medium URL to a custom Webflow field
  url: "original-url",
  # Map publication date to a custom Webflow field
  published_at: "publish-date",
  # Special handling for images - will be converted to { url: image_url }
  image_url: "featured-image"
}
```

### Command Line Interface

You have two options to run the sync:

1. Using command-line arguments:

```bash
$ medium_to_webflow sync \
  --medium-username=your-username \
  --webflow-api-token=your-token \
  --webflow-collection-id=your-collection-id \
  --field-mappings=title:name,guid:slug,url:medium-url,published_at:published-at,author:author,image_url:image,category:category
```

2. Using a configuration file:

First, generate a sample configuration file:

```bash
$ medium_to_webflow init
# Creates config/medium_to_webflow.rb with environment variables support

# Or specify a custom path
$ medium_to_webflow init --path=./config.rb
```

Then run the sync using the config file:

```bash
$ medium_to_webflow sync -c config/medium_to_webflow.rb
```

You can also mix both approaches - use a config file for defaults and override specific options via command line.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
