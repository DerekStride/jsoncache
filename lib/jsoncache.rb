require 'json'

# JSONCache is a simple interface to cache JSON based API calls
module JSONCache
  attr_accessor :cache_directory, :symbolize_json

  private

  # Retrieves cached data for the specified key and caches the data provided
  # if the cache isn't valid.
  # @param [String] key
  # @param [Fixnum] delta The upperbound timestamp difference of a valid
  #   cache, 0 if the result doesn't go stale.
  def cache(key, delta = 0)
    return retrieve_cache(key) if cached?(key, delta)
    result = yield
    cache_file(key, result)
    result
  end

  # Create, if necessary, and return a cache directory
  def cache_dir
    cache_path = File.join('/tmp', @cache_directory || 'jsoncache')
    Dir.mkdir(cache_path) unless Dir.exist?(cache_path)
    cache_path
  end

  # Determine whether a file is cached and healthy
  # @param [String] key The key in which to check for cached data.
  # @param [Fixnum] delta The upperbound timestamp difference of a valid
  #   cache, 0 if the result doesn't go stale.
  def cached?(key, delta = 0)
    timestamp = timestamp_from_key(key)
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
  def cache_file(key, data)
    cache_path = cache_dir
    existing_file = filename_from_key(key)
    last_path = "#{cache_path}/#{existing_file}"
    return unless data.respond_to?(:to_h)
    File.delete(last_path) if existing_file && File.exist?(last_path)
    File.write(
      "#{cache_path}/#{key}#{Time.now.to_i}.json",
      JSON.generate(data.to_h))
  end

  # Retrieves a cached value from a key
  # @param [String] key The key in which to check for cached data.
  def retrieve_cache(key)
    filename = filename_from_key(key)
    return nil if filename.nil?
    @symbolize_json = false if @symbolize_json.nil?
    JSON.parse(
      File.read("#{cache_dir}/#{filename}"),
      symbolize_names: @symbolize_json)
  end

  # Gets an existing file from a uri if it exists
  # @param [String] key The key in which to check for cached data.
  def filename_from_key(key)
    Dir.foreach(cache_dir) do |filename|
      next unless filename.include?(key)
      return filename
    end
  end

  # Extracts a timestamp from an existing file
  # @param [String] key The key in which to check for cached data.
  def timestamp_from_key(key)
    path = filename_from_key(key)
    return 0 if path.nil?
    path.slice(/#{key}.*/)
      .gsub(/^#{key}/, '')
      .chomp('.json')
      .to_i
  end
end
