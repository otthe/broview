require "json"
require "digest"
require "time"
require_relative "../lib/broview/file_cache"

RSpec.describe Broview::FileCache do
  let(:cache_file_path) { Broview::FileCache::CACHE_FILE }
  let(:test_file_path) { File.expand_path("explosion.wav", __dir__) }
  let(:test_file_hash) { Digest::MD5.hexdigest("dummy_content") }
  let(:mock_cache) do
    {
      test_file_hash => {
        "path" => test_file_path,
        "sound_level" => -10.5,
        "last_analyzed" => "2024-01-01T00:00:00Z",
      },
    }
  end

  before do
    allow(File).to receive(:exist?).with(test_file_path).and_return(true)
    allow(File).to receive(:exist?).with(cache_file_path).and_return(false)
  end

  after do
    File.delete(cache_file_path) if File.exist?(cache_file_path)
  end

  describe ".load_cache" do
    it "returns empty hash if cache file does not exist" do
      expect(described_class.load_cache).to eq({})
    end

    it "loads cache from the cache file if it exists" do
      allow(File).to receive(:exist?).with(cache_file_path).and_return(true)
      allow(File).to receive(:read).with(cache_file_path).and_return(JSON.generate(mock_cache))

      expect(described_class.load_cache).to eq(mock_cache)
    end
  end

  describe ".file_hash" do
    it "generates correct MD5 hash for a file" do
      allow(Digest::MD5).to receive(:file).and_return(instance_double(Digest::MD5, hexdigest: test_file_hash))

      expect(described_class.file_hash(test_file_path)).to eq(test_file_hash)
    end
  end

  describe ".get_cached_sound_level" do
    context "when cache contains the file and file exists" do
      before do
        allow(described_class).to receive(:load_cache).and_return(mock_cache)
      end
    end

    context "when cache does not contain the file" do
      before do
        allow(described_class).to receive(:load_cache).and_return({})
      end

      it "returns nil" do
        expect(described_class.get_cached_sound_level(test_file_path)).to be_nil
      end
    end

    context "when file in the cache does not exist" do
      before do
        allow(described_class).to receive(:load_cache).and_return(mock_cache)
        allow(File).to receive(:exist?).with(test_file_path).and_return(false)
      end

      it "returns nil" do
        expect(described_class.get_cached_sound_level(test_file_path)).to be_nil
      end
    end
  end

  describe ".cache_sound_level" do
    it "saves the sound level for a file to the cache" do
      allow(described_class).to receive(:load_cache).and_return({})
      allow(described_class).to receive(:file_hash).with(test_file_path).and_return(test_file_hash)

      described_class.cache_sound_level(test_file_path, -15.0)

      saved_cache = JSON.parse(File.read(cache_file_path))
      expect(saved_cache[test_file_hash]["path"]).to eq(test_file_path)
      expect(saved_cache[test_file_hash]["sound_level"]).to eq(-15.0)
      expect(Time.parse(saved_cache[test_file_hash]["last_analyzed"])).to be_within(5).of(Time.now.utc)
    end
  end
end
