# JSONCache

A simple JSON Cache for use with HTTP APIs

## Instructions

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
