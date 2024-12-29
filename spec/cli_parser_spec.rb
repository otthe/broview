require "optparse"
require_relative "../lib/broview/cli_parser"

RSpec.describe Broview::CliParser do
  let(:options) { {} }

  before do
    allow($stdout).to receive(:puts)
    allow($stderr).to receive(:puts)
  end

  context "with valid arguments" do
    it "sets directory option when valid directory is provided" do
      args = ["--dir=/tmp"]
      described_class.parse(options, args)
      expect(options[:dir]).to eq(File.expand_path("/tmp"))
    end

    it "sets port option when a valid port is provided" do
      args = ["--port=8080"]
      described_class.parse(options, args)
      expect(options[:port]).to eq(8080)
    end
  end

  context "with invalid arguments" do
    it "exits with error when invalid dirctory is provided" do
      args = ["--dir=/nonexistent"]
      expect { described_class.parse(options, args) }.to raise_error(SystemExit)
    end

    it "exits with error when invalid port is provided" do
      args = ["--port=70000"]
      expect { described_class.parse(options, args) }.to raise_error(SystemExit)
    end
  end

  context "with help message" do
    it "prints help message and exits when --options is provided" do
      args = ["--options"]
      expect { described_class.parse(options, args) }.to raise_error(SystemExit)
    end
  end

  context "with no arguments" do
    it "does not modify options hash" do
      args = []
      described_class.parse(options, args)
      expect(options).to be_empty
    end
  end
end
