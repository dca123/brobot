class BotController < Sinatra::Base

  post '/events' do
    File.open('params.log', 'a') do |f|
      f << params
    end
    help_string = "/give @devinda +25 He is Super Cool !"
    case params['text'].to_s.strip
    when 'help'
      "Give a Delt Bro Points. #{help_string}"
    when /\@\w*\s\+\d*\s\w*/
      text = params['text'].to_s.strip.split()
      reciever = text[0]
      points = text[1]
      reason = text[2..-1].join(" ")
      sender = "@" + params['user_name']
      puts points, reciever, reason
      if reason == ''
        "You didn't input a reason. Try again with the proper input - #{help_string}"
      elsif reciever == sender
        "You can't give yourself points !"
      else
        token = ENV['SLACK_BOT_TOKEN']
        message = "https://slack.com/api/chat.postMessage?token=#{token}&channel=testchannel&as_user=1&link_names=1&text="
          text = "#{sender} just gave #{reciever}#{points} for '#{reason}'"
          HTTParty.post("#{message}#{text}")
          points[0] = ''
          Point.create(giver: sender, reciever: reciever, points:points.to_i, reason: reason)
          "BroBot will update the database shortly and post it on #bropoints"
      end
    else
      "Your command was incorrect. Try again with the proper input - #{help_string}"
    end
  end
end
