require 'spec_helper'
require 'pp'
require_relative '../lib/jsoncache'

# Simple Test Class for the JSONCache Module
class JSONCacheTest
  include JSONCache

  def initialize
  end

  def cache(*args)
    super(*args)
  end

  def cache_file(*args)
    super(*args)
  end

  def cached?(*args)
    super(*args)
  end

  def retrieve_cache(*args)
    super(*args)
  end

  def cache_dir(*args)
    super(*args)
  end

  def timestamp_from_key(*args)
    super(*args)
  end

  def filename_from_key(*args)
    super(*args)
  end
end

describe JSONCache do
  def clear_all(dir)
    return unless Dir.exist?(dir)
    Dir.foreach(dir) do |filename|
      next if %w(. ..).include?(filename)
      File.delete("#{dir}/#{filename}")
    end
    Dir.rmdir(dir) if Dir.exist?(dir)
  end

  before :all do
    @cache_directory = 'test'
    @cache = "/tmp/#{@cache_directory}"
    @key = 'match1234567890'
    @filename_root = "#{@cache}/#{@key}"
    @sample_data = { 'hello' => 'world' }
    @options = {
      cache_directory: @cache_directory
    }
    clear_all(@cache)
  end

  before :each do
    @uut = JSONCacheTest.new
  end

  after :each do
    clear_all(@cache)
  end

  describe '#new' do
    it 'takes no parameters and returns a JSONCacheTest object' do
      expect(@uut).to be_an_instance_of(JSONCacheTest)
    end
  end

  describe '#cached?' do
    context 'no cache exists' do
      it 'should not be cached if no cache exists' do
        expect(
          @uut.cached?(@key, @options)).to be false
      end
    end
    context 'a cache exists' do
      before :each do
        @uut.cache(@key, @options) { @sample_data }
      end

      it 'should be valid if it doesnt become invalid' do
        expect(@uut.cached?(@key, @options)).to be true
      end
      it 'should be valid if it is within the healthy timeframe' do
        expect(@uut.cached?(@key, @options.merge(delta: 20))).to be true
      end
      it 'should be invaild if it is outside the healthy timeframe' do
        expect(@uut.cached?(@key, @options.merge(delta: -1))).to be false
      end
    end
  end

  describe '#cache' do
    context 'data not cached' do
      it 'should yield control if there is no valid cache' do
        expect { |b| JSONCache.cache(@key, @options, &b) }.to(
          yield_control.once)
      end
      it 'should yield yield without args' do
        expect { |b| JSONCache.cache(@key, @options, &b) }.not_to(
          yield_with_args)
      end
    end

    context 'data cached' do
      before :each do
        @cached_data = JSONCache.cache(@key, @options) { @sample_data }
      end
      after :each do
        clear_all(@cache)
      end

      it 'should not yield control' do
        expect { |b| JSONCache.cache(@key, @options, &b) }.not_to(
          yield_control)
      end
      it 'should return the data from the block if no cache exists' do
        expect(@cached_data).to eq @sample_data
      end
      it 'should return the old data if the cache is valid' do
        new_data = { 'seeya' => 'later' }
        valid_cache_data = JSONCache.cache(@key, @options) { new_data }
        expect(valid_cache_data).to eq @cached_data
      end
      it 'should return the new data if the cache is invalid' do
        new_data = { 'seeya' => 'later' }
        invalid_cache_data = JSONCache.cache(
          @key,
          @options.merge(delta: -1)) { new_data }
        expect(invalid_cache_data).to eq new_data
      end
    end
  end

  describe '#cache_file' do
    before :each do
      @uut.cache_file(@key, @sample_data, @options)
    end

    it 'should cache the data into the proper file' do
      filename = @uut.filename_from_key(@key, @cache_directory)
      expect(File.exist?("#{@cache}/#{filename}")).to be true
    end
    it 'should cache the expected data' do
      filename = @uut.filename_from_key(@key, @cache_directory)
      content = File.read("#{@cache}/#{filename}")
      expect(content).to match(/.*hello.*world.*/)
    end
  end

  describe '#retrieve_cache' do
    it 'should be nil if no cache exists' do
      retrieved = @uut.retrieve_cache(@key, @options)
      expect(retrieved).to be_nil
    end
    it 'should retrieve and parse the cached contents' do
      @uut.cache(@key, @options) { @sample_data }
      retrieved = @uut.retrieve_cache(@key, @options)
      expect(retrieved).to eq @sample_data
    end
  end

  describe '#filename_from_key' do
    it 'should be nil if no file exists' do
      filename = @uut.filename_from_key(@key, @cache_directory)
      expect(filename).to be_nil
    end
    it 'should return the filename for the cached file' do
      @uut.cache(@key, @options) { @sample_data }
      filename = @uut.filename_from_key(@key, @cache_directory)
      expect(File.exist?("#{@cache}/#{filename}")).to be true
    end
  end

  describe '#timestamp_from_key' do
    it 'should be zero if there is no cache' do
      timestamp = @uut.timestamp_from_key(@key, @cache_directory)
      expect(timestamp).to be_zero
    end
    it 'should be close to what it was when cached' do
      @uut.cache(@key, @options) { @sample_data }
      timestamp = @uut.timestamp_from_key(@key, @cache_directory)
      expect(timestamp).to be_within(2).of(Time.now.to_i)
    end
  end

  describe '#cache_dir' do
    it 'shouldnt exist to start with' do
      expect(Dir.exist?(@cache)).to be false
    end
    it 'should create the directory and be /tmp/@cache_directory' do
      dir = @uut.cache_dir(@cache_directory)
      expect(dir).to eq @cache
      expect(Dir.exist?(@cache)).to be true
    end
    it 'should handle nil' do
      default = '/tmp/jsoncache'
      dir = @uut.cache_dir(nil)
      expect(dir).to eq default
      expect(Dir.exist?(default)).to be true
    end
  end
end
