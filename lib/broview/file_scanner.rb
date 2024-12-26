module Broview
    class FileScanner
      def self.get_supported_extensions
        config = Broview::Config.load_config['default']['supported_extensions']
        config['images'] + config['audio'] + config['video']
      end

      def self.get_media_from_dir(dir = Dir.pwd)
        supported_extensions = get_supported_extensions
        Dir.entries(dir).select do |file|
          supported_extensions.include?(File.extname(file).downcase)
        end
      end
    end
end