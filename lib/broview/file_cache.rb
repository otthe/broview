require 'json'
require 'digest'
require 'time'

module Broview
  class FileCache
    CACHE_FILE = File.expand_path('../../config/cache.json', __dir__)

    def self.load_cache
      return JSON.parse(File.read(CACHE_FILE)) if File.exist?(CACHE_FILE)
      {}
    end

    def self.save_cache(cache)
      File.write(CACHE_FILE, JSON.pretty_generate(cache))
    end

    def self.file_hash(file_path)
      Digest::MD5.file(file_path).hexdigest
    end

    def self.get_cached_sound_level(file_path)
      cache = load_cache
      file_hash = file_hash(file_path)

      if cache.key?(file_hash) && File.exist?(cache[file_hash]['path'])
        cache[file_hash]['sound_level']
      else
        nil
      end
    end

    def self.cache_sound_level(file_path, sound_level)
      cache = load_cache
      file_hash = file_hash(file_path)

      cache[file_hash] = {
        'path' => file_path,
        'sound_level' => sound_level,
        'last_analyzed' => Time.now.utc.iso8601
      }

      save_cache(cache)
    end
  end

end