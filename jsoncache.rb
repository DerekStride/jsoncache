require 'json'

# JSONCache is a simple interface to cache JSON based API calls
module JSONCache
  attr_accessor :cache_directory

  # Determine whether a file is cached and healthy
  # @param [String] uri the uri in which to check for a cached call.
  # @param [boolean] stale whether or not a cached file can go stale.
  # @param [Fixnum] delta the upperbound timestamp difference of a valid cache.
  def cached?(uri, delta = 0)
    timestamp = timestamp_from_uri(uri)
    if timestamp.zero?
      false
    elsif !delta.zero?
      (Time.now.to_i - timestamp) < delta
    else
      true
    end
  end

  # Cache the result from the uri
  # @param [Hash] response the response to cache.
  # @param [String] uri the uri in which to check for a cached call.
  def cache_file(response, uri)
    cache_path = cache_dir
    existing_file = filename_from_uri(uri)
    last_path = "#{cache_path}/#{existing_file}"
    File.delete(last_path) if existing_file && File.exist?(last_path)
    File.write(
      "#{cache_path}/#{uri_to_file_path_root(uri)}#{Time.now.to_i}.json",
      JSON.generate(response))
  end

  def retrieve_cache(uri, params = {})
    JSON.parse(
      File.read("#{cache_dir}/#{filename_from_uri(uri)}"),
      params)
  end

  private

  # Create, if necessary, and return a cache directory
  def cache_dir
    cache_path = File.join('/tmp', @cache_directory)
    Dir.mkdir(cache_path) unless Dir.exist?(cache_path)
    cache_path
  end

  # Converts uri to the base portion of the filename
  # TODO requires overwrite
  # def uri_to_file_path_root(uri)
  #   uri.gsub(%r{[\.\/]|https:\/\/.*v\d\.\d|\?api=.*}, '')
  # end

  # Gets an existing file from a uri if it exists
  def filename_from_uri(uri)
    root_path = uri_to_file_path_root(uri)
    Dir.foreach(cache_dir) do |filename|
      next unless filename.include?(root_path)
      return filename
    end
  end

  # Extracts a timestamp from an existing file
  def timestamp_from_uri(uri)
    path = filename_from_uri(uri)
    return 0 if path.nil?
    last_pattern = uri_to_file_path_root(uri)
    path.slice(/#{last_pattern}.*/)
      .gsub(/^#{last_pattern}/, '')
      .chomp('.json')
      .to_i
  end
end
