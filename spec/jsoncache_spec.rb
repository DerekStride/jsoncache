require 'spec_helper'
require 'pp'
require_relative '../lib/jsoncache'

# j
class JSONCacheTest
  extend JSONCache

  def perform(json = nil)
    json
  end

  def expired(json = nil)
    json
  end

  cache :perform
  cache :expired, expiry: -1
end

describe JSONCacheTest do
  before :all do
    @uut = JSONCacheTest.new
    @sample_data = { hello: 'world' }
  end

  describe '#perform' do
    include FakeFS::SpecHelpers

    context 'data not cached' do
      it 'should create a cache' do
        expect(File.exist?(JSONCache::FileCache::CACHE_DIR)).to be false
        @uut.perform
        expect(File.exist?(JSONCache::FileCache::CACHE_DIR)).to be true
      end
      it 'should create a cache based on the arguments' do
        expect(File.exist?(JSONCache::FileCache::CACHE_DIR)).to be false
        @uut.perform(@sample_data)
        expect(File.exist?(JSONCache::FileCache::CACHE_DIR)).to be true
      end
    end

    context 'data cached' do
      before :each do
        @cached_data = @uut.perform(@sample_data)
        @key = JSONCache::FileCache.send(:normalize, @sample_data)
      end

      it 'should read from the cache' do
        expect(@uut.perform(@sample_data)).to eq @cached_data
      end
      it 'should return the old data if the cache is valid' do
        expect(@uut.perform(@key)).to eq @cached_data
      end
      it 'should return the new data if the cache is invalid' do
        expect(@uut.expired(@key)).not_to eq @cached_data
        expect(@uut.expired(@key)).to eq @key
      end
    end
  end
end
