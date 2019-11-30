ENV['SINATRA_ENV'] ||= 'development'

require_relative './config/environment'

task :console do
  Pry.start
end

task :post_top5 do
  require_relative './config/environment'
  require './app/top_5_helper.rb'
  include Sinatra::TopPoint
  token = ENV['SLACK_BOT_TOKEN']
  message = "https://slack.com/api/chat.postMessage?token=#{token}&channel=testchannel&as_user=1&link_names=1&text="
  text = topPointsString.to_s
  puts Time.now, text
  HTTParty.post("#{message}Top 5 Delts for this week are - #{topPointsString}")
end
