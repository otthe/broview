require 'open3'

module Broview
  class AudioAnalyzer
    def self.get_sound_level(file_path)
      command = "ffmpeg -i #{file_path.shellescape} -filter:a volumedetect -f null /dev/null"
      output, error, status = Open3.capture3(command)

      if status.success?
        if error =~ /mean_volume: ([-\d.]+) dB/
          $1.to_f
        else
          nil #unable to parse mean volume
        end
      else
        nil #command failed
      end
      
    end
  end
end 