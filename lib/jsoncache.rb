require 'json'

# JSONCache is a simple interface to cache JSON based API calls
module JSONCache
  extend self

  # Retrieves cached data for the specified key and caches the data provided
  # if the cache isn't valid.
  # @param [String] key The key in which to check for cached data.
  # @param [Hash] options A hash of the parameters to use when caching.
  # Accepted options parameters
  # => [Boolean] symbolize
  # => [String] cache_directory
  # => [Fixnum] delta
  def cache(key, options = {})
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
  # @param [String] key The key in which to check for cached data.
  # @param [Hash] options A hash of the parameters to use when caching.
  def cached?(key, options = {})
    timestamp = timestamp_from_key(key, options[:cache_directory])
    delta = options[:delta] || 0
    if timestamp.zero?
      false
    elsif delta.zero?
      true
    else
      (Time.now.to_i - timestamp) < delta
    end
  end

  # Cache the result from the uri
  # @param [String] key The key in which to check for cached data.
  # @param [Hash] data The response to cache.
  # @param [Hash] options A hash of the parameters to use when caching.
  def cache_file(key, data, options = {})
    return unless data.respond_to?(:to_h)

    cache_path = cache_dir(options[:cache_directory])
    existing_file = filename_from_key(key, options[:cache_directory])
    last_path = "#{cache_path}/#{existing_file}"

    File.delete(last_path) if existing_file && File.exist?(last_path)
    File.write(
      "#{cache_path}/#{key}#{Time.now.to_i}.json",
      JSON.generate(data.to_h))
  end

  # Retrieves a cached value from a key
  # @param [String] key The key in which to check for cached data.
  # @param [Hash] options A hash of the parameters to use when caching.
  def retrieve_cache(key, options = {})
    directory = options[:cache_directory]
    filename = filename_from_key(key, directory)
    return nil if filename.nil?
    symbolize = options[:symbolize] || false
    JSON.parse(
      File.read("#{cache_dir(directory)}/#{filename}"),
      symbolize_names: symbolize)
  end

  ########################################################################
  # Helpers
  ########################################################################

  # Create, if necessary, and return a cache directory
  # @param [String] directory The name of the cache directory.
  def cache_dir(directory)
    directory ||= 'jsoncache'
    cache_path = File.join('/tmp', directory)
    Dir.mkdir(cache_path) unless Dir.exist?(cache_path)
    cache_path
  end

  # Gets an existing file from a uri if it exists
  # @param [String] key The key in which to check for cached data.
  # @param [String] directory The name of the cache directory.
  def filename_from_key(key, directory)
    directory ||= 'jsoncache'
    Dir.foreach(cache_dir(directory)) do |filename|
      next unless filename.include?(key)
      return filename
    end
  end

  # Extracts a timestamp from an existing file
  # @param [String] key The key in which to check for cached data.
  # @param [String] directory The name of the cache directory.
  def timestamp_from_key(key, directory)
    path = filename_from_key(key, directory)
    return 0 if path.nil?
    path.slice(/#{key}.*/)
      .gsub(/^#{key}/, '')
      .chomp('.json')
      .to_i
  end
end
