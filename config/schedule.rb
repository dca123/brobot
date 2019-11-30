# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "/home/devinda/Projects/brobot/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every :sunday, at: "06:55 PM" do
  # job_type :runner, "cd #{path} && RAILS_ENV=development /home/devinda/.rvm/wrappers/brobot/bundle exec rails runner ':task' :output"
  rake "post_top5"
end
