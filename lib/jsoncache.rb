require 'json'

# JSONCache is a simple interface to cache JSON based API calls
#
# Author::    Derek Stride  (mailto:djgstride@gmail.com)
# License::   MIT
#
# This module provides an easy to use class method +cache+ which caches json
# in a key-value fashion to the filesystem in /tmp/jsoncache.
module JSONCache
  extend self

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
  def cache(key, options = {})
    options = defaults.merge(options)
    return retrieve_cache(key, options) if cached?(key, options)
    result = yield
    cache_file(key, result, options)
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
  def cached?(key, options = {})
    options = defaults.merge(options)
    timestamp = timestamp_from_key(key, options[:cache_directory])
    expiry = options[:expiry]
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
  def cache_file(key, data, options = {})
    options = defaults.merge(options)
    begin
      content = JSON.generate(data)
    rescue
      return
    end

    cache_path = cache_dir(options[:cache_directory])
    existing_file = filename_from_key(key, options[:cache_directory])
    last_path = "#{cache_path}/#{existing_file}"

    File.delete(last_path) if existing_file && File.exist?(last_path)
    File.write(
      "#{cache_path}/#{key}#{Time.now.to_i}.json",
      content)
  end

  # Retrieves a cached value from a key
  #
  # ==== Parameters
  #
  # +key+:: +String+ The key in which to check for cached data.
  # +options+:: +Hash+ A hash of the parameters to use when caching.
  def retrieve_cache(key, options = {})
    options = defaults.merge(options)
    directory = options[:cache_directory]
    filename = filename_from_key(key, directory)
    return nil if filename.nil?
    JSON.parse(
      File.read("#{cache_dir(directory)}/#{filename}"),
      symbolize_names: options[:symbolize])
  end

  ########################################################################
  # Helpers
  ########################################################################

  # Create, if necessary, and return a cache directory
  #
  # ==== Parameters
  #
  # +directory+:: +String+ The name of the cache directory.
  def cache_dir(directory)
    directory ||= defaults[:cache_directory]
    cache_path = File.join('/tmp', directory)
    FileUtils.mkdir_p(cache_path) unless Dir.exist?(cache_path)
    cache_path
  end

  # Gets an existing file from a uri if it exists
  #
  # ==== Parameters
  #
  # +key+:: +String+ The key in which to check for cached data.
  # +directory+:: +String+ The name of the cache directory.
  def filename_from_key(key, directory)
    Dir.foreach(cache_dir(directory)) do |filename|
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
  def timestamp_from_key(key, directory)
    path = filename_from_key(key, directory)
    return 0 if path.nil?
    path.slice(/#{key}.*/)
      .gsub(/^#{key}/, '')
      .chomp('.json')
      .to_i
  end

  def defaults
    { symbolize: false, cache_directory: 'jsoncache', expiry: 0 }
  end
end
