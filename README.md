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

There are two ways to configure and use the gem:

### 1. Using a Configuration File (Recommended)

First, generate a sample configuration file:

```bash
$ medium_to_webflow init
# Creates config/medium_to_webflow.rb with environment variables support

# Or specify a custom path
$ medium_to_webflow init --path=./config.rb
```

The configuration file will look like this:

```ruby
MediumToWebflow.configure do |config|
  # Required settings
  config.medium_username = ENV.fetch("MEDIUM_USERNAME", nil)
  config.webflow_api_token = ENV.fetch("WEBFLOW_API_TOKEN", nil)
  config.webflow_collection_id = ENV.fetch("WEBFLOW_COLLECTION_ID", nil)

  # Field mappings from Medium post attributes to Webflow field names
  config.field_mappings = {
    # Required mappings
    title: "name",          # Maps to Webflow's name field
    guid: "slug",           # Maps to Webflow's slug field

    # Optional mappings (customize based on your collection)
    url: "source-url",      # Maps to a custom field
    published_at: "date",   # Maps to a date field
    author: "author",       # Maps to an author field
    image_url: "image",     # Maps to an image field (converted to { url: value })
    category: "category"    # Maps to a category field
  }
end
```

Then run the sync:

```bash
$ medium_to_webflow sync -c config/medium_to_webflow.rb
```

### 2. Using Command Line Options

You can also run the sync directly with command line options:

```bash
$ medium_to_webflow sync \
  --medium-username=your-username \
  --webflow-api-token=your-token \
  --webflow-collection-id=your-collection-id \
  --field-mappings=title:name,guid:slug,url:medium-url
```

### Available Options

```bash
$ medium_to_webflow sync [options]
    -u, --medium-username=USERNAME    Medium username (without the @ symbol)
    -t, --webflow-api-token=TOKEN    Webflow API token with CMS permissions
    -l, --webflow-collection-id=ID   The ID of the Webflow collection where posts will be imported
    -m, --field-mappings=MAPPINGS    Map Medium post fields to Webflow collection fields
    -v, --verbose                    Enable verbose logging
    -f, --force-update              Force update existing posts (default: false)
    -c, --config=PATH                Path to a Ruby config file
    -h, --help                       Show this help message
```

#### Logging Options

The verbose flag (`-v`) will output detailed debugging information during the sync process, which can be helpful for troubleshooting issues.

#### Update Behavior

The `--force-update` flag controls how existing posts are handled:

- When set to false (default), the sync will skip posts that already exist in Webflow
- When true, existing posts will be updated with the latest content from Medium

### Available Medium Post Attributes

When configuring field mappings, you can use any of these Medium post attributes:

- `title`: The post title
- `url`: The Medium post URL
- `published_at`: Publication date
- `author`: Post author
- `image_url`: Featured image URL
- `category`: Post category
- `guid`: The post's unique identifier

### Required Webflow Fields

Your field mappings must include these Webflow fields:

- `name`: The item name in Webflow
- `slug`: The URL slug in Webflow

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
