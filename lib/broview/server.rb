require 'sinatra'
require 'rack/mime'
require 'launchy'
require 'socket'

require_relative 'file_scanner'

module Broview
    class Server
        def self.start(dir = Dir.pwd, port = 4567)
            kill_existing_server(port)

            BroviewApp.set :root, dir
            BroviewApp.set :public_folder, dir
            BroviewApp.set :views, File.expand_path('views', __dir__)
            BroviewApp.set :port, port

            server_thread = Thread.new{ BroviewApp.run! }

            wait_for_server(port)

            Launchy.open("http://localhost:#{port}")

            server_thread.join
        end

        def self.kill_existing_server(port)
            begin
                server_socket = TCPSocket.new('localhost', port)
                server_socket.close
                puts "Server is already running on port #{port}. Killing it..."

                # this might - and probably will - need some OS specific tweeking in the future
                `lsof -i :#{port} | grep LISTEN | awk '{print $2}' | xargs kill -9`
            rescue Errno::ECONNREFUSED
                puts "no server running on port #{port}"
            end
        end

        def self.wait_for_server(port, timeout=10)
            start_time = Time.now
            loop do
                begin
                    TCPSocket.new('localhost', port).close
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
    set :public_folder, Proc.new {settings.root}
    set :views, File.expand_path('views', __dir__)

    before do
        content_type Rack::Mime.mime_type(File.extname(request.path_info))
    end

    puts "Root directory: #{BroviewApp.root}"
    puts "Public folder: #{BroviewApp.public_folder}"
    puts "Views folder: #{BroviewApp.views}"
    puts "Environment: #{BroviewApp.environment}"
    
    get '/' do
      content_type 'text/html'

      config = Broview::Config.load_config['default']['supported_extensions']
      @image_extensions = config['images']
      @audio_extensions = config['audio']
      @video_extensions = config['video']

      @media_files = Broview::FileScanner.get_media_from_dir(settings.root)
      erb :index
    end
end
