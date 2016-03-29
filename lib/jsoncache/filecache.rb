require 'json'
require 'fileutils'

module JSONCache
  # This module provides an easy to use class method +cache+ which caches json
  # in a key-value fashion to the filesystem in /tmp/jsoncache.
  module FileCache
    extend self

    CACHE_DIR = '/tmp/jsoncache'.freeze

    # Retrieves cached data for the specified key and caches the data provided
    # if the cache isn't valid. Specify a code block after the method call that
    # returns a hash and it will be cached.
    #
    # ==== Parameters
    #
    # +key+:: +String+ The key in which to check for cached data.
    # +options+:: +Hash+ A hash of the parameters to use when caching.
    #
    # ==== Options
    #
    # Accepted options
    #
    # +:symbolize+:: +Boolean+ Symbolize keys while parsing JSON.
    # +:cache_directory+:: +String+ The folder name in /tmp to use as the cache.
    # +:expiry+:: +Fixnum+ The validity time of the cache in seconds.
    #
    # ==== Examples
    #
    #   def get_response(uri)
    #     JSONCache.cache(uri_to_key(uri), expiry: 120) do
    #       query_some_json_api(uri)
    #     end
    #   end
    def cache(*key, expiry: 0)
      normalized_key = normalize(key)
      return retrieve_cache(normalized_key) if cached?(normalized_key, expiry)
      result = yield
      cache_file(normalized_key, result)
      result
    end

    private

    ########################################################################
    # Core Caching
    ########################################################################

    # Determine whether a file is cached and healthy
    #
    # ==== Parameters
    #
    # +key+:: +String+ The key in which to check for cached data.
    # +options+:: +Hash+ A hash of the parameters to use when caching.
    def cached?(key, expiry)
      timestamp = timestamp_from_key(key)
      if timestamp.zero?
        false
      elsif expiry.zero?
        true
      else
        (Time.now.to_i - timestamp) < expiry
      end
    end

    # Cache the result from the uri
    #
    # ==== Parameters
    #
    # +key+:: +String+ The key in which to check for cached data.
    # +data+:: +Hash+ The data to cache.
    # +options+:: +Hash+ A hash of the parameters to use when caching.
    def cache_file(key, data)
      begin
        content = JSON.generate(data)
      rescue
        return
      end

      existing_file = filename_from_key(key)
      last_path = "#{cache_dir}/#{existing_file}"

      File.delete(last_path) if existing_file && File.exist?(last_path)
      File.write("#{cache_dir}/#{key}#{Time.now.to_i}.json", content)
    end

    # Retrieves a cached value from a key
    #
    # ==== Parameters
    #
    # +key+:: +String+ The key in which to check for cached data.
    # +options+:: +Hash+ A hash of the parameters to use when caching.
    def retrieve_cache(key)
      filename = filename_from_key(key)
      return nil if filename.nil?
      JSON.parse(File.read("#{cache_dir}/#{filename}"), symbolize_names: true)
    end

    ########################################################################
    # Helpers
    ########################################################################

    # Create, if necessary, and return a cache directory
    #
    # ==== Parameters
    #
    # +directory+:: +String+ The name of the cache directory.
    def cache_dir
      FileUtils.mkdir_p(CACHE_DIR) unless Dir.exist?(CACHE_DIR)
      CACHE_DIR
    end

    # Gets an existing file from a uri if it exists
    #
    # ==== Parameters
    #
    # +key+:: +String+ The key in which to check for cached data.
    # +directory+:: +String+ The name of the cache directory.
    def filename_from_key(key)
      key = 'jsoncache' if key.empty?
      Dir.foreach(cache_dir) do |filename|
        next unless filename.include?(key)
        return filename
      end
    end

    # Extracts a timestamp from an existing file
    #
    # ==== Parameters
    #
    # +key+:: +String+ The key in which to check for cached data.
    # +directory+:: +String+ The name of the cache directory.
    def timestamp_from_key(key)
      path = filename_from_key(key)
      return 0 if path.nil?
      path.slice(/#{key}.*/)
          .gsub(/^#{key}/, '')
          .chomp('.json')
          .to_i
    end

    def normalize(key)
      key.to_s.delete('{}()[]<>."\'=+:\/?~`!@#$%^&*|;, ')
    end
  end
end
