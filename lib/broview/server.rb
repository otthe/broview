# Server-class launches new server session everytime the program is started,
# it also handles routing and kills previous sessions running on the same port.

require "sinatra"
require "rack/mime"
require "launchy"
require "socket"

require_relative "file_scanner"

module Broview
  class Server
    def self.start(dir = Dir.pwd, port = 4567)
      kill_existing_server(port)

      BroviewApp.set :root, dir
      BroviewApp.set :public_folder, dir
      # BroviewApp.set :views, File.expand_path("views", __dir__)
      BroviewApp.set :views, File.expand_path("../../themes", __dir__)
      BroviewApp.set :port, port

      server_thread = Thread.new { BroviewApp.run! }

      wait_for_server(port)

      Launchy.open("http://#{Broview::Config.get(:host) || "localhost"}:#{port}")

      server_thread.join
    end

    def self.kill_existing_server(port)
      begin
        server_socket = TCPSocket.new("localhost", port)
        server_socket.close
        puts "Server is already running on port #{port}. Killing it..."

        # this might - and probably will - need some OS specific tweeking in the future
        `lsof -i :#{port} | grep LISTEN | awk '{print $2}' | xargs kill -9`
      rescue Errno::ECONNREFUSED
        puts "no server running on port #{port}"
      end
    end

    def self.wait_for_server(port, timeout = 10)
      start_time = Time.now
      loop do
        begin
          TCPSocket.new("localhost", port).close
          puts "server is up and running on port #{port}"
          break
        rescue Errno::ECONNREFUSED
          if Time.now - start_time > timeout
            puts "Server failed to start within #{timeout} seconds."
            exit(1)
          end
          sleep 0.1
        end
      end
    end
  end
end

class BroviewApp < Sinatra::Base
  set :public_folder, Proc.new { settings.root }
  #set :views, File.expand_path("views", __dir__)
  set :views, File.expand_path("../../themes", __dir__)

  before do
    content_type Rack::Mime.mime_type(File.extname(request.path_info))
  end

  puts "Root directory: #{BroviewApp.root}"
  puts "Public folder: #{BroviewApp.public_folder}"
  puts "Views folder: #{BroviewApp.views}"
  puts "Environment: #{BroviewApp.environment}"

  get "/" do
    content_type "text/html"

    #load extensions from config
    config = Broview::Config.load_config["default"]["supported_extensions"] rescue {}
    @image_extensions = config["images"] || []
    @audio_extensions = config["audio"] || []
    @video_extensions = config["video"] || []

    @media_files = Broview::FileScanner.get_media_from_dir(settings.root).map do |file|
      file_path = File.join(settings.root, file)
      sound_level = Broview::AudioAnalyzer.get_sound_level(file_path) || 0

      base_sound_level = Broview::Config.get(:base_sound_level) || -23.0
      volume_adjustment = Broview::AudioAnalyzer.adjust_sound_level(base_sound_level, sound_level)

      {
        name: file,
        path: file,
        type: File.extname(file).downcase,
        sound_level: sound_level || 0,
        volume_adjustment: volume_adjustment,
      }
    end

    @base_file_path = settings.root
    erb :"#{Broview::Config.get(:theme) || "default"}"
  end

  get "/media/:file" do |file|
    file_path = File.join(settings.root, file)
    halt 404, "File not found" unless File.exist?(file_path)

    content_type Rack::Mime.mime_type(File.extname(file_path))
    send_file file_path
  end
end
