ENV['SINATRA_ENV'] ||= 'development'

require 'bundler/setup'

Bundler.require(:default, ENV['SINATRA_ENV'])

configure :development do
  Mongoid.load!('./db/database.yml', :development)
end
require_all 'app'
