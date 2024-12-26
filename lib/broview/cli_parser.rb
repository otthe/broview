require 'optparse'

module Broview
    class CliParser
        def self.parse(options, args)
            OptionParser.new do |opts|
                opts.banner = "Usage: broview [options]"

                opts.on("-dDIR", "--dir=DIR", "Set the directory to serve files from (default: current directory)") do |dir|
                    if Dir.exist?(dir)
                        options[:dir] = File.expand_path(dir)
                    else
                        puts "error: directory '#{dir}' does not exist"
                        exit(1)
                    end
                end

                opts.on("-pPORT", "--port=PORT", Integer, "Set the port for the server (default: 4567)") do |port|
                    if port > 0 && port <= 65535
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

                #this doesnt work correctly because sinatra/rack overwrites them with it's own "--help" arg
                opts.on("-h", "--help", "Prints this help message") do
                    puts opts
                    exit
                end
            end.parse!(args) # explicitly parse only Broview arguments (by default rack and sinatra overwrites these options)

            #clear any remaining arguments to prevent sinatra/rack from processing them!
            #ARGV.clear
        end

    end
end
