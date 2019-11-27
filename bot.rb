require 'sinatra'
require 'json'
require 'slack-ruby-client'
require "./point"

class BroBot < Sinatra::Base

  # post '/events' do
  #   event = JSON.parse(request.body.read)
  #   puts event
  #   case event['type']
  #   when 'url_verification'
  #     event['challenge']
  #   when 'event_callback'
  #     puts "hi"
  #   end
  # end


end
#
# Slack.configure do |config|
#   config.token = ENV['SLACK_API_TOKEN']
#   raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
# end
#
# client = Slack::Web::Client.new
#
# client.auth_test
#
# # client.chat_postMessage(channel: '#testchannel', text: 'Hello World', as_user: true)
#
# Point.create(giver: "devinda", reciever: "ss", points: 20)
