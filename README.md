# JSONCache

A simple JSON Cache for use with HTTP APIs

## Instructions

```ruby
require 'jsoncache'
JSONCache.cache(key, options) do
  # Code that returns a Hash
end
```

The cache method takes a key that identifies that cached data. The options parameter can be used to configure the results and operation. The acceptable keys are as followed.
* cache_directory: String - The name of the directory where to store the cache. Default: 'jsoncache' (Internally stored at /tmp/{cache_directory})
* symbolize: Boolean - Whether or not to use symbolize_json flag while parsing
* delta: Fixnum - The expiry time in seconds.

## Example

```ruby
# Simple Test Class for the JSONCache Module
class JSONCacheTest
  def query(uri, timeout = 0)
    JSONCache.cache(uri_to_key(uri),
                    cache_directory: 'example',
                    symbolize: true,
                    delta: 300) do
      response = HTTP.get_response(uri)
      JSON.parse(response.body) if response.code = '200'
    end
  end
end
```
