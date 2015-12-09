# JSONCache

A simple JSON Cache for use with HTTP APIs

## Instructions

```ruby
require 'jsoncache'
```

You need to mixin the JSONCache module to your class that requires caching, see an example of using it below.

After that you should be able to call the caching functions most importantly
* `cache(key, delta = 0, &block)`

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
