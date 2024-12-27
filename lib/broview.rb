# frozen_string_literal: true

require_relative "broview/file_scanner"
require_relative "broview/server"
require_relative "broview/cli_parser"
require_relative "broview/config"
require_relative "broview/audio_analyzer"
require_relative "broview/file_cache"

require_relative "broview/version"

puts "Broview Version: #{Broview::VERSION}"
