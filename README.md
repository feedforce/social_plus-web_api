# SocialPlus::WebApi

[![Travis Status](https://img.shields.io/travis/feedforce/social_plus-web_api.svg?style=flat-square)][travisci]
[![License](https://img.shields.io/github/license/feedforce/social_plus-web_api.svg?style=flat-square)][license]
[![Gem](https://img.shields.io/gem/v/social_plus-web_api.svg?style=flat-square)][gem-link]

[travisci]: https://travis-ci.org/feedforce/social_plus-web_api
[license]: https://github.com/feedforce/social_plus-web_api/blob/master/LICENSE.txt
[gem-link]: http://badge.fury.io/rb/social_plus-web_api

This gem provides fundamental access to Social Plus's Web API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'social_plus-web_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install social_plus-web_api

## Usage

Instantiate an instance of {SocialPlus::WebApi::Client} with a valid API key.

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
