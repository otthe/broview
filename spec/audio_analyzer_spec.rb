require_relative "../lib/broview/audio_analyzer"
require_relative "../lib/broview/file_cache"

RSpec.describe Broview::AudioAnalyzer do
  let(:file_path) { "/path/to/audio.mp3" }

  before do
    allow(Broview::FileCache).to receive(:get_cached_sound_level)
    allow(Broview::FileCache).to receive(:cache_sound_level)

    allow(Open3).to receive(:capture3)
  end

  describe ".get_sound_level" do
    context "when a cached sound level exists" do
      it "returns the cached value" do
        allow(Broview::FileCache).to receive(:get_cached_sound_level).with(file_path).and_return(-12.3)

        result = described_class.get_sound_level(file_path)
        expect(result).to eq(-12.3)
      end
    end

    context "when no cached sound level exists" do
      it "runs ffmpeg and parses the sound level" do
        allow(Broview::FileCache).to receive(:get_cached_sound_level).with(file_path).and_return(nil)
        ffmpeg_output = "Some output\nmean_volume: -15.6 dB\nMore output"
        allow(Open3).to receive(:capture3).and_return([nil, ffmpeg_output, instance_double(Process::Status, success?: true)])

        result = described_class.get_sound_level(file_path)
        expect(result).to eq(-15.6)
        expect(Broview::FileCache).to have_received(:cache_sound_level).with(file_path, -15.6)
      end

      it "returns nil if ffmpeg fails" do
        allow(Broview::FileCache).to receive(:get_cached_sound_level).with(file_path).and_return(nil)
        allow(Open3).to receive(:capture3).and_return([nil, "error", instance_double(Process::Status, success?: false)])

        result = described_class.get_sound_level(file_path)
        expect(result).to be_nil
      end

      it "returns nil if ffmpeg output is invalid" do
        allow(Broview::FileCache).to receive(:get_cached_sound_level).with(file_path).and_return(nil)
        allow(Open3).to receive(:capture3).and_return([nil, "Some unrelated output", instance_double(Process::Status, success?: true)])

        result = described_class.get_sound_level(file_path)
        expect(result).to be_nil
      end
    end
  end

  describe ".adjust_sound_level" do
    it "calculates the adjustment factor correctly" do
      #if something goes wrong with the audio, we will come back to this.
      #expect(described_class.adjust_sound_level(-10, -20)).to eq(10 ** (10 / 20.0))
      expect(described_class.adjust_sound_level(-20, -10)).to eq(10 ** (-10 / 20.0))
    end

    it "clamps the result between 0 and 1" do
      expect(described_class.adjust_sound_level(-100, 100)).to eq(0)
      expect(described_class.adjust_sound_level(100, -100)).to eq(1)
    end
  end
end
