# frozen_string_literal: true

require "rspec"
require_relative "../lib/broview/server"
require_relative "../lib/broview/config"

# this test will fail unless server is running
# RSpec.describe Broview::Server do
#   describe "#start" do
#     it "checks if server is running on specific port" do
#       response = `curl 127.0.0.1:4567`
#       expect(response).not_to be_empty
#     end
#   end
# end

# RSpec.describe Broview::Server.kill_existing_server(4567) do
#   describe "#end" do
#     it "checks that the server running on specific port gets killed" do
#       response_before_killing = `curl 127.0.0.1:4567`
#       Broview::Server.kill_existing_server(4567)
#       response_after_killing = `curl 127.0.0.1:4567`
#       expect(response_before_killing).not_to eq(response_after_killing)
#     end
#   end
# end
