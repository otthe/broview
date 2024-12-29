# frozen_string_literal: true

# AudioAnalyzer-class uses FFMPEG to find out the sound level of video/audio -file.
# This information is later used to adjust sound level to user defined base_sound_level.

require "open3"
require "etc"

module Broview
  # optimization done by analyizing:
  #--------------------------------
  # only first 15s, (-t 15)
  # using 4 threads, (-threads thread_count)
  # skipping video processing (-vn)
  # reducing sample rate (-ar 22050) https://en.wikipedia.org/wiki/Analog-to-digital_converter
  # reducing audio channels to 1 (-ac 1)
  class AudioAnalyzer
    def self.get_sound_level(file_path)
      cached_level = Broview::FileCache.get_cached_sound_level(file_path)
      return cached_level unless cached_level.nil?

      thread_count = Etc.nprocessors || 4
      command = "ffmpeg -i #{file_path.shellescape} -t 15 -threads #{thread_count} -ac 1 -ar 22050 -vn -filter:a volumedetect -f null /dev/null"
      _, error, status = Open3.capture3(command)

      return unless status.success? && error =~ /mean_volume: ([-\d.]+) dB/

      sound_level = ::Regexp.last_match(1).to_f
      Broview::FileCache.cache_sound_level(file_path, sound_level)
      sound_level
    end

    def self.adjust_sound_level(base_sound_level, sound_level)
      (10 ** ((base_sound_level - sound_level) / 20.0)).clamp(0, 1)
    end
  end
end
