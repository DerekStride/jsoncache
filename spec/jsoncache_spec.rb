require 'spec_helper'
require 'pp'
require_relative '../lib/jsoncache'

describe JSONCache do
  before :all do
    @cache_directory = 'test'
    @cache = "/tmp/#{@cache_directory}"
    @key = 'match1234567890'
    @sample_data = { 'hello' => 'world' }
    @options = {
      cache_directory: @cache_directory
    }
  end

  describe '#cache' do
    include FakeFS::SpecHelpers

    context 'data not cached' do
      it 'should yield control if there is no valid cache' do
        expect { |b| JSONCache.cache(@key, @options, &b) }.to(
          yield_control.once)
      end
      it 'should yield without args' do
        expect { |b| JSONCache.cache(@key, @options, &b) }.not_to(
          yield_with_args)
      end
      it 'should create a cache' do
        expect(File.exist?(@cache)).to be false
        JSONCache.cache(@key, @options) { @sample_data }
        expect(File.exist?(@cache)).to be true
      end
    end

    context 'data cached' do
      before :each do
        @cached_data = JSONCache.cache(@key, @options) { @sample_data }
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
          @options.merge(expiry: -1)) { new_data }
        expect(invalid_cache_data).to eq new_data
      end
    end
  end
end
