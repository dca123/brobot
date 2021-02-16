
![Bro Bot](https://i.imgur.com/HtXPR77.png)

--- 
# Table of Contents
- [Problem](#problem)
- [Solution](#solution)
- [Technologies](#technologies)
- [Usage](#usage)
# Problem
In my fraternity, at the end of the chapter each week we would nominate a member of the chapter as the *Delt of the week*. This was done by taking into account the good deeds done by the nominees and voting for who we thought was most deserving of this post for the week. However, since this nomination was only done at the end of the week, it often meant that deeds might be forgotten over the week and thus the system encouraged *greater* deeds at a low frequency. 
# Solution
Brobot lives on our fraternity's slack and is called into action when a member pings for it. A member can ping for it whenever they think another member should be recognized for a good deed. Therefore, this solution encourages members to do *good deeds* frequently as opposed to *greater deeds infrequently*. As members ping the bot as soon as *good deed* was recognized, it also means that these deeds won't be forgotten over the week. Finally, at the end of each week, before the chapter begins, the bro bot will calculate and announce the *Delt of the week*.

The backend is run on [Sinatra](http://sinatrarb.com/) where [Mongodb](https://www.mongodb.com/) is used to store the points. A URL is exposed to the Slack bot (BroBot), which will add a *good deed* to the database. A cron job is run at the end of each week to calculate the *Delt of the Week* and is pushed onto the Slack via the BroBot. 
# Technologies
- [Sinatra](http://sinatrarb.com/)
- [Slack API](https://api.slack.com/)
- [Mongodb](https://www.mongodb.com/)
# Usage
1. Install dependencies
 ```
 bundle install
 ```
 2. Create a Slack Bot and add its token to the environment variable `SLACK_BOT_TOKEN`
 3.  Setup database
 ```
bundle exec rake db:create
bundle exec rake db:setup
```
4. Seed with random data (optional)
```
bundle exec rake db:seed
```
 4. Run the backend
 ```
rackup 
``` 
5. Navigate to [localhost:9292](http://localhost:9292/)
