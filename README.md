# SocialPlus::WebApi

This gem provides fundamental access to Social Plus's Web API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'social_plus-web_api', github: 'feedforce/social_plus-web_api'
```

And then execute:

    $ bundle

## Usage

Instantiate an instance of SocialPlus::WebApi::Client with a valid API key.

```ruby
client = SocialPlus::WebApi::Client.new(API_KEY)
```

### API access via GET method

```ruby
begin
  result = client.execute(:api_name, arguments_as_hash)
rescue SocialPlus::WebApi::ApiError => e
  # handle exceptions
end
```

### API access via POST method

```ruby
begin
  result = client.execute(:api_name, arguments_as_hash, via: :post)
rescue SocialPlus::WebApi::ApiError => e
  # handle exceptions
end
```
