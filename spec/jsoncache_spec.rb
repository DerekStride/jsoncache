require 'spec_helper'
require 'jsoncache'

# Simple Test Class for the JSONCache Module
class JSONCacheTest
  include JSONCache

  attr_accessor :cache_directory

  def initialize
    @cache_directory = 'test'
  end

  def uri_to_file_path_root(uri)
    uri.gsub(%r{[\.\/]|https:\/\/.*v\d\.\d|\?api=.*}, '')
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
    @uut = JSONCacheTest.new
    @cache = "/tmp/#{@uut.cache_directory}"
    @uri1 = 'https://na.api.pvp.net/api/lol/na/v2.2/match/1234567890'
    @file_path_root1 = 'match1234567890'
    @filename_root = "#{@cache}/#{@file_path_root1}"
    clear_all(@cache)
  end

  after :each do
    clear_all(@cache)
  end

  describe '#new' do
    it 'takes no parameters and returns a JSONCacheTest object' do
      expect(@uut).to be_an_instance_of(JSONCacheTest)
    end
  end

  describe '#uri_to_file_path_root' do
    it 'should properly parse the uri' do
      expect(@uut.uri_to_file_path_root(@uri1)).to eq @file_path_root1
    end
  end

  describe '#cached?' do
    it 'should cache a file and show the results' do
      expect(@uut.cached?(@uri1)).to be false
      @uut.cache_file({ hello: 'world' }, @uri1)
      expect(@uut.cached?(@uri1)).to be true
      expect(@uut.cached?(@uri1, 20)).to be true
      expect(@uut.cached?(@uri1, -1)).to be false
    end
  end

  describe '#cache_file' do
    it 'should create a cache directory and save the file' do
      expect(Dir.exist?(@cache)).to be false
      @uut.cache_file({ hello: 'world' }, @uri1)
      filename = "#{@filename_root}#{Time.now.to_i}.json"
      expect(Dir.exist?(@cache)).to be true
      expect(File.exist?(filename))
    end
  end

  describe '#retrieve_cache' do
    it 'should retrieve and parse the cached contents' do
      @uut.cache_file({ hello: 'world' }, @uri1)
      content = @uut.retrieve_cache(@uri1)
      expect(content.key?('hello')).to be true
      expect(content['hello']).to eq 'world'
    end
  end
end
