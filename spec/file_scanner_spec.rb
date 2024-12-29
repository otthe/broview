# require "fileutils"
# require_relative "../file_scanner"
# require_relative "../config"

# RSpec.describe Broview::FileScanner do
#   let(:mock_supported_extensions) do
#     [".jpg", ".png", ".mp3", ".mp4", ".wav"]
#   end

#   let(:mock_config) do
#     {
#       "default" => {
#         "supported_extensions" => {
#           "images" => [".jpg", ".png"],
#           "audio" => [".mp3", ".wav"],
#           "video" => [".mp4"]
#         }
#       }
#     }
#   end

#   before do
#     allow(Broview::Config).to receive(:load_config).and_return(mock_config)
#   end

#   describe ".get_supported_extensions" do
#     it "returns a combined list of supported extensions" do
#       expect(described_class.get_supported_extensions).to eq(mock_supported_extensions)
#     end
#   end

#   describe ".get_media_from_dir" do
#     let(:test_dir) { Dir.mktmpdir }

#     before do
#       FileUtils.touch(File.join(test_dir, "image.jpg"))
#       FileUtils.touch(File.join(test_dir, "audio.mp3"))
#       FileUtils.touch(File.join(test_dir, "video.mp4"))
#       FileUtils.touch(File.join(test_dir, "document.txt"))
#       FileUtils.touch(File.join(test_dir, "unsupported_file.xyz"))
#     end

#     #clean temp dir
#     after do
#       FileUtils.remove_entry(test_dir)
#     end

#     it "returns only files with supported extensions" do
#       media_files = described_class.get_media_from_dir(test_dir)
#       expect(media_files).to match_array(["image.jpg", "audio.mp3", "video.mp4"])
#     end

#     it "return empty array if the directory has no supported files" do
#       empty_dir = Dir.mktmpdir
#       media_files = described_class.get_media_from_dir(empty_dir)
#       expect(media_files).to eq([])
#       FileUtils.remove_entry(empty_dir)
#     end

#     it "defaults to current directory when no directory is specified" do
#       allow(Dir).to receive(:pwd).and_return(test_dir)
#       media_files = described_class.get_media_from_dir
#       expect(media_files).to match_array(["image.jpg", "audio.mp3", "video.mp4"])
#     end
#   end
# end
