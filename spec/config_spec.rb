require "yaml"
require_relative "../lib/broview/config"

RSpec.describe Broview::Config do
  let(:mock_config) do
    {
      "default" => {
        "host" => "localhost",
        "port" => 4567,
        "base_sound_level" => -23.0,
        "supported_extensions" => {
          "images" => [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".svg", ".avif"],
          "audio" => [".mp3", ".wav", ".ogg", ".m4a", ".flac"],
          "video" => [".mp4", ".avi", ".mkv", ".mov", ".webm"],
        },
        "theme" => "default",
      },
    }
  end

  before do
    allow(YAML).to receive(:load_file).and_return(mock_config)
  end

  describe ".load_config" do
    it "loads configuration from the YAML file" do
      config = described_class.load_config
      expect(config).to eq(mock_config)
    end
  end

  describe ".get" do
    it "retrieves host value" do
      expect(described_class.get(:host)).to eq("localhost")
    end

    it "retrieves port value" do
      expect(described_class.get(:port)).to eq(4567)
    end

    it "retrieves base_sound_level value" do
      expect(described_class.get(:base_sound_level)).to eq(-23.0)
    end

    it "retrieves supported extensions for images" do
      expect(described_class.get(:supported_extensions)["images"]).to eq(
        [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".svg", ".avif"]
      )
    end

    it "retrieves supported extensions for audio" do
      expect(described_class.get(:supported_extensions)["audio"]).to eq(
        [".mp3", ".wav", ".ogg", ".m4a", ".flac"]
      )
    end

    it "retrieves supported extensions for video" do
      expect(described_class.get(:supported_extensions)["video"]).to eq(
        [".mp4", ".avi", ".mkv", ".mov", ".webm"]
      )
    end

    it "retrieves theme value" do
      expect(described_class.get(:theme)).to eq("default")
    end

    it "returns nil for missing key" do
      expect(described_class.get(:nonexistent_key)).to be_nil
    end
  end
end
