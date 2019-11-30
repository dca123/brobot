
ENV['RACK_ENV'] = 'test'

require './config/environment'
require 'spec_helper'

shared_examples "valid token" do |params|
  before :each do
     post '/slash', params
   end
  it "returns status 200 OK" do
   expect(last_response.status).to eq 200
  end
end

describe BotController do
  Mongoid.load!('./db/database.yml', :test)
  extend Rack::Test::Methods
  def app
    BotController.new
  end
  context "POST /slash" do
    context "invalid token" do
      before :each do
         post '/slash'
       end
      it "returns status 200 OK" do
       expect(last_response.status).to eq 200
      end
      it "returns a message saying invalid token" do
        expect(last_response.body).to eq("Ops! Looks like the application is not authorized! Please review the token configuration.")
      end
    end
    context "valid token" do
      token = ENV['SLACK_VERIFICATION_TOKEN']
      context "message = help" do
        params={token: token, text: 'help'}
        include_examples("valid token", params)
        it "returns the help message" do
          expect(last_response.body).to eq "Give a Delt Bro Points. /give @devinda +25 He is Super Cool !"
        end
      end
      context 'message = empty message' do
        params={token: token, text: ' '}
        include_examples("valid token", params)
        it "returns the help message" do
          expect(last_response.body).to eq "Your command was incorrect. Try again with the proper input - /give @devinda +25 He is Super Cool !"
        end
      end
      context 'Valid Message' do
        valid_params = {token: token, text: '@devinda +4 Here is a reason', user_name: 'henry'}
        before :each do
          post '/slash', params: valid_params
        end
        it 'matches regex' do
          expect(last_request['text']).to match /\@\w*\s\+\d*\s\w*/
        end
        include_examples("valid token" , valid_params)
        it 'adds a point to the database' do
          record = Point.where(giver: '@henry', reciever: '@devinda', reason: 'Here is a reason')
          expect(record.count).to be >= 1
          expect(last_response.body).to eq "BroBot will update the database shortly and post it on #bropoints"
        end
      end
      context 'Invalid Message' do
        valid_params = {token: token, text: '@devinda Here is a reason', user_name: 'devinda'}
        before :each do
          post '/slash', params: valid_params
        end
        it 'matches regex' do
          expect(last_request['text']).not_to match /\@\w*\s\+\d*\s\w*/
        end
        include_examples("valid token", valid_params)
      end
      context 'Sender is Reciever' do
        valid_params = {token: token, text: '@devinda +20 5656', user_name: 'devinda'}
        before :each do
          post '/slash', valid_params
        end
        it 'matches regex' do
          expect(last_response.body).to include "You can't give yourself points !"
        end
        include_examples("valid token", valid_params)
      end
      context "Top Stats" do
        valid_params = {token: token, text: 'top', user_name: 'henry'}
        before :each do
           post '/slash', valid_params
         end
        it "gives top 5 delts from last week" do
          results = last_response.body.split()
          expect(last_response.body).to include "Top 5 Delts for this week are -"
          expect(results.length).to eq 18
        end
        context "stats with reason" do
          it "gives top 5 delts from last week & the reasons"
        end
      end
      context "Stats by Top" do |variable|
        valid_params = {token: token, text: 'stats @devinda', user_name: 'henry'}
        before :each do
          post '/slash', valid_params
         end
        it "gives total score for last week" do
          expect(last_response.body).to match /\w* got \d* points since \w*/
        end
        context "gives total score for last week with reason" do
          it "gives top 5 delts from last week & the reasons"
        end
      end
      context "Adding Emoticons" do
        context "1 star" do
          it "adds 1 point to reciever"
          it "reduces 1 point from sender"
        end
        context "2 star" do
          it "adds 1 point to reciever"
          it "reduces 1 point from sender"
        end
        context "3 star" do
          it "adds 1 point to reciever"
          it "reduces 1 point from sender"
        end
      end
      context "Removing Emoticons" do
        context "1 star" do
          it "removes 1 point to reciever"
          it "adds 1 point from sender"
        end
        context "2 star" do
          it "removes 1 point to reciever"
          it "adds 1 point from sender"
        end
        context "3 star" do
          it "removes 1 point to reciever"
          it "adds 1 point from sender"
        end
      end
      context "Posts Top 5 Delts Every week at 6.55pm on #bropoints"  do
        it "posts message on slack"
      end
    end
  end
end
