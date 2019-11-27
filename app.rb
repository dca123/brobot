require 'mongoid'
require './bot'

configure do
  Mongoid.load!('./database.yml', :development)
end

x = BroBot.new
