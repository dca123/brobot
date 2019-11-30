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
      if event['item_user'] == BotID and event['user'] != BotID
        eventUser = User.find_or_create_by(username: event['user'])
        token = ENV['SLACK_BOT_TOKEN']
        messageText = "https://slack.com/api/chat.postMessage?token=#{token}&channel=#{event['user']}&as_user=1&text="
        case event['type']
        when 'reaction_added'
          item = event['item']
          event_ts = item['ts']
          message = Point.where(slack_ts: event_ts).first
          case event['reaction']
          when 'grinning'
            if eventUser.points >=1
              Reaction.create(username: event['user'], reaction_name: event['reaction'], slack_ts: event_ts)
              message.update_attributes(points: message.points + 1)
              eventUser.update_attributes(points: eventUser.points - 1)
            else
              text = "Your last vote was not counted sine you only have #{eventUser.points} points remaining"
              HTTParty.post("#{messageText}#{text}")
              "no votes left"
            end
          when 'hugging_face'
            if eventUser.points >=2
              Reaction.create(username: event['user'], reaction_name: event['reaction'], slack_ts: event_ts)
              message.update_attributes(points: message.points + 2)
              eventUser.update_attributes(points: eventUser.points - 2)
            else
              text = "Your last vote was not counted sine you only have #{eventUser.points} points remaining"
              HTTParty.post("#{messageText}#{text}")
              "no votes left"
            end
          when 'star-struck'
            if eventUser.points >= 3
              Reaction.create(username: event['user'], reaction_name: event['reaction'], slack_ts: event_ts)
              message.update_attributes(points: message.points + 3)
              eventUser.update_attributes(points: eventUser.points -  3)
            else
              text = "Your last vote was not counted sine you only have #{eventUser.points} points remaining"
              HTTParty.post("#{messageText}#{text}")
              "no votes left"
            end
          end
        when 'reaction_removed'
          item = event['item']
          event_ts = item['ts']
          message = Point.where(slack_ts: event_ts).first
          ## TODO:  removing points correctly
          reaction = Reaction.where(username:event['user'], reaction_name: event['reaction'], slack_ts: event_ts).first
          unless reaction.nil?
            case event['reaction']
            when 'grinning'
              message.update_attributes(points: message.points - 1)
              eventUser.update_attributes(points: eventUser.points + 1)
            when 'hugging_face'
              message.update_attributes(points: message.points - 2)
              eventUser.update_attributes(points: eventUser.points + 2)
            when 'star-struck'
              message.update_attributes(points: message.points - 3)
              eventUser.update_attributes(points: eventUser.points + 3)
            end
            reaction.destroy
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
    help_string = "/give @devinda +25 He is Super Cool ! \nType /give points for current points available\n/give stats @username => How many points a delt has recieved in the last week\n/give top => to see top 5 current delts"
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
      eventUser = User.find_or_create_by(username: params['user_id'])
      if reciever == sender
        message = "https://slack.com/api/chat.postMessage?token=#{token}&channel=testchannel&as_user=1&link_names=1&text="
        text = "#{sender} just tried to give themselves points lol !'"
        HTTParty.post("#{message}#{text}")
        "You can't give yourself points !"
      elsif points > 5
        "You can only give up to 5 points per Delt !"
      elsif points > eventUser.points
        "You only have #{eventUser.points} points left to award !"
      else
        message = "https://slack.com/api/chat.postMessage?token=#{token}&channel=testchannel&as_user=1&link_names=1&text="
        text = "#{sender} just gave #{reciever} #{points} points for '#{reason}'"
        res = HTTParty.post("#{message}#{text}")
        newPoint = Point.create(giver: sender, reciever: reciever, points:points, reason: reason, ts: Time.now, slack_ts: res['ts'])
        emoticons = ['grinning', 'hugging_face', 'star-struck']
        emoticons.each do |emotion|
          emoticonMessage = "https://slack.com/api/reactions.add?token=#{token}&channel=C8W98HSMN&name=#{emotion}&timestamp=#{res['ts']}"
          HTTParty.post(emoticonMessage)
        end
        eventUser.update_attributes(points: eventUser.points - points)
        "BroBot will update the database shortly and post it on #bropoints"
      end
    when /points\s*/
      username = params['user_id']
      user = User.find_by(username: username)
      "You have #{user.points} points remaining for this week"
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
