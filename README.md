# JSONCache

A simple JSON Cache for use with HTTP APIs

## Instructions

```ruby
require 'jsoncache'
```

You need to need to set the `@cache_directory` instance variable and implement the `uri_to_file_path_root(uri)` in order for the mixin to function properly.

After that you should be able to call the caching functions
* `cache(key, delta = 0)`

## Example

```ruby
# Simple Test Class for the JSONCache Module
class JSONCacheTest
  include JSONCache

  def query(uri, timeout = 0)
    cache(uri_to_key(uri), timeout) do
      response = HTTP.get_response(uri)
      JSON.parse(response.body) if response.code = '200'
    end
  end
end
```
