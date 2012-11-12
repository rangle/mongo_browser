$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "mongo_browser"

require "rspec"
require "capybara"
require "capybara/rspec"
require "socket"

require "simplecov"
SimpleCov.start

def find_available_port
  server = TCPServer.new("127.0.0.1", 0)
  server.addr[1]
ensure
  server.close if server
end

MongoBrowser.mongodb_host = "localhost"
MongoBrowser.mongodb_port = find_available_port

Capybara.app = MongoBrowser::Application

require "support/mongod"

RSpec.configure do |config|
  config.before do
    Mongod.start_server
    Mongod.load_fixtures
  end
end

at_exit do
  Mongod.clean_up
end
