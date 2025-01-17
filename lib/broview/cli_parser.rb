# frozen_string_literal: true

# CliParser-class is used to run Broview with extra arguments

require "optparse"

module Broview
  class CliParser
    def self.parse(options, args)
      OptionParser.new do |opts|
        opts.banner = "Usage: broview [options]"

        opts.on("-dDIR", "--dir=DIR",
                "Set the directory to serve files from (default: current directory)") do |dir|
          if Dir.exist?(dir)
            options[:dir] = File.expand_path(dir)
          else
            puts "error: directory '#{dir}' does not exist"
            exit(1)
          end
        end

        opts.on("-pPORT", "--port=PORT", Integer, "Set the port for the server (default: 4567)") do |port|
          if port.positive? && port <= 65_535
            options[:port] = port
          else
            puts "error: invalid port number. must be between 1 and 65535"
            exit(1)
          end
        end

        opts.on("-o", "--options", "Prints this help message") do
          puts opts
          exit
        end
      end.parse!(args)
    end
  end
end
