require 'jsoncache/filecache'

# JSONCache is a simple interface to cache JSON based API calls
#
# Author::    Derek Stride  (mailto:djgstride@gmail.com)
# License::   MIT
module JSONCache
  def cache(method, options = {})
    original = "__uncached_#{method}__"
    ([Class, Module].include?(self.class) ? self : self.class).class_eval do
      alias_method original, method
      private original
      define_method(method) do |*args|
        JSONCache::FileCache.cache(*args, options) { send(original, *args) }
      end
    end
  end
end
