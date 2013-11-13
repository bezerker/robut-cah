Bundler.require(:default, :test)
require 'minitest/autorun'
require 'mocks/connection_mock'
require 'mocks/presence_mock'

Robut::ConnectionMock.configure do |config|
  config.nick = "Robut t. Robot"
  config.mention_name = "robut"
end