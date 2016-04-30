# JSONCache [![Build Status](https://travis-ci.org/DerekStride/jsoncache.svg?branch=dynamic-caching-based-on-arguments)](https://travis-ci.org/DerekStride/jsoncache)

A simple JSON Cache for use with HTTP APIs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsoncache'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install jsoncache
```

## Usage

Include it in the class or module you want to use it in.

```ruby
extend JSONCache
```

To enable caching for a method use the include class method `cache`.

```ruby
cache :expensive_method, expiry: 300
```

Note: the `cache` method call has to come after the method definition.

## Example

```ruby
require 'jsoncache'

Class A
  extend JSONCache

  def expensive_method(args)
    # code
  end

  cache :expensive_method, expiry: 300
end
```

The cache method will the existing method and provide it with caching to the local filesystem. You can set a TTL (time to live) for the cache by setting the `expiry` value in seconds.
