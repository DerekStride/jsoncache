# JSONCache

A simple JSON Cache for use with HTTP APIs

## Instructions

```ruby
require 'jsoncache'
```

You need to need to set the `@cache_directory` instance variable and implement the `uri_to_file_path_root(uri)` in order for the mixin to function properly.

After that you should be able to call the caching functions
* `cached?(uri, delta = 0)`
* `cache_file(response, uri)`
* `retrieve_cache(uri, params = {})`

## Example

```ruby
# Simple Test Class for the JSONCache Module
class JSONCacheTest
  include JSONCache

  def initialize
    @cache_directory = 'test'
  end

  def uri_to_file_path_root(uri)
    uri.gsub(%r{[\.\/]|https:\/\/.*v\d\.\d|\?api=.*}, '')
  end
end
```
