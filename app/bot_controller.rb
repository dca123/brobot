require './app/slack_authorizer'
require './app/top_5_helper.rb'
class BotController < Sinatra::Base
  helpers Sinatra::TopPoint
  use SlackAuthorizer
  BotID = 'UQQPR6YBT'
  post '/events' do
    res =  JSON.parse(env['body'])
    case res['type']
    when 'url_verification'
      res['challenge']
    when 'event_callback'
      event = res['event']
      if event['item_user'] == BotID
        case event['type']
        when 'reaction_added'
          item = event['item']
          event_ts = item['ts']
          message = Point.where(slack_ts: event_ts).first
          case event['reaction']
          when 'grinning'
            message.update_attributes(points: message.points + 1)
            puts 'grinning'
          when 'hugging_face'
            puts 'hugging_face'
            message.update_attributes(points: message.points + 2)
          when 'star-struck'
            puts 'star-struck'
            message.update_attributes(points: message.points + 3)
          end
        when 'reaction_removed'
          item = event['item']
          event_ts = item['ts']
          message = Point.where(slack_ts: event_ts).first
          case event['reaction']
          when 'grinning'
            message.update_attributes(points: message.points - 1)
            puts 'grinning'
          when 'hugging_face'
            puts 'hugging_face'
            message.update_attributes(points: message.points - 2)
          when 'star-struck'
            puts 'star-struck'
            message.update_attributes(points: message.points - 3)
          end
        end
      end
    else
    end
  end
  post '/slash' do
    # File.open('params.log', 'a') do |f|
    #   f << params
    # end
    help_string = "/give @devinda +25 He is Super Cool !"
    token = ENV['SLACK_BOT_TOKEN']
    case params['text'].to_s.strip
    when 'help'
      "Give a Delt Bro Points. #{help_string}"
    when /\@\w*\s\+\d*\s\w*/
      text = params['text'].to_s.strip.split()
      reciever = text[0]
      points = text[1][1..-1].to_i
      reason = text[2..-1].join(" ")
      sender = "@" + params['user_name']
      if reciever == sender
        message = "https://slack.com/api/chat.postMessage?token=#{token}&channel=testchannel&as_user=1&link_names=1&text="
        text = "#{sender} just tried to give themselves points lol !'"
        HTTParty.post("#{message}#{text}")
        "You can't give yourself points !"
      elsif points > 5
        "You can only give up to 5 points per Delt !"
      else
        message = "https://slack.com/api/chat.postMessage?token=#{token}&channel=testchannel&as_user=1&link_names=1&text="
        text = "#{sender} just gave #{reciever} #{points} points for '#{reason}'"
        res = HTTParty.post("#{message}#{text}")
        puts res['ts']
        newPoint = Point.create(giver: sender, reciever: reciever, points:(points - 6), reason: reason, ts: Time.now, slack_ts: res['ts'])
        emoticons = ['grinning', 'hugging_face', 'star-struck']
        emoticons.each do |emotion|
          emoticonMessage = "https://slack.com/api/reactions.add?token=#{token}&channel=C8W98HSMN&name=#{emotion}&timestamp=#{res['ts']}"
          HTTParty.post(emoticonMessage)
        end
        emoticonMessage = "https://slack.com/api/reactions.add?token=#{token}&channel=C8W98HSMN&name=star-struck&timestamp=#{res['ts']}"
        HTTParty.post(emoticonMessage)
        "BroBot will update the database shortly and post it on #bropoints"
      end
    when /stats\s\@\w*/
      username = params['text'].to_s.strip.split()[1]
      startDay = DateTime.now.change({hour: 18, min: 55, sec: 0}) - DateTime.now.wday
      points = Point.where(reciever: username, :ts.gte => startDay).sum(:points)
      "<#{username}> got #{points} points since #{startDay.strftime('%m/%d/%Y')}"
    when "top"
      message = "https://slack.com/api/chat.postMessage?token=#{token}&channel=testchannel&as_user=1&link_names=1&text="
      text = topPointsString.to_s
      "Top 5 Delts for this week are - #{topPointsString}"
    else
      "Your command was incorrect. Try again with the proper input - #{help_string}"
    end
  end
end
