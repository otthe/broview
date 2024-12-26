module Broview
    class FileScanner
        IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .gif .bmp .webp]
        AUDIO_EXTENSIONS = %w[.mp3 .wav .ogg .m4a .flac]
        VIDEO_EXTENSIONS = %w[.mp4 .avi .mkv .mov .webm]

        SUPPORTED_EXTENSIONS = IMAGE_EXTENSIONS + AUDIO_EXTENSIONS + VIDEO_EXTENSIONS

        # def self.get_images_from_dir(dir = Dir.pwd)
        #     files = Dir.entries(dir)
        #
        #     image_files = files.select do |file|
        #         IMAGE_EXTENSIONS.include?(File.extname(file).downcase)
        #     end
        #
        #     image_files
        # end

        def self.get_media_from_dir(directory = Dir.pwd)
            Dir.entries(directory).select do |file|
                SUPPORTED_EXTENSIONS.include?(File.extname(file).downcase)
            end
        end
    end
end
