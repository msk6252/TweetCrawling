require 'rubygems'
require 'bundler'
Bundler.require

require 'twitter'
require 'time'
require './SecretManager.rb'
require './Firestore.rb'


class TwitterCrawling
  attr_reader :day_before, :today
  def initialize
    ENV['TZ'] = 'Asia/Tokyo'
    secretmanager = SecretManager.new("TwitterCrawling")

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = secretmanager.get_secret("TWITTER_CONSUMER_KEY")
      config.consumer_secret     = secretmanager.get_secret("TWITTER_CONSUMER_SECRET")
      config.access_token        = secretmanager.get_secret("TWITTER_ACCESS_TOKEN")
      config.access_token_secret = secretmanager.get_secret("TWITTER_ACCESS_TOKEN_SECRET")
    end

    @day_before = (Time.now - 3600).strftime("%Y-%m-%d_%H:00:00_JST")
    @today = Time.now.strftime("%Y-%m-%d_%H:00:00_JST")
  end
  
  def get_users
    users = []

    secretmanager = SecretManager.new("TwitterCrawling")
    project_id = secretmanager.get_secret("FIRESTORE_PROJECT_ID")
    Firestore.get_data(project_id, "users", "config.json").get do | user |
      users << user.data[:name]
    end
    return users
  end

  def get_movies_url(user)
    regexp_url = /https?:\/\/[\S]+\.mp4.*/
    
    @client.search("from:#{user} since:#{@day_before} until:#{@today} filter:videos", {result_type: "recent", tweet_mode: "extended"}).collect do |tweet|
      if tweet[:media].count > 0
        if tweet[:media][0][:video_info]
          if tweet[:media][0][:video_info][:variants].count > 0
              content = { user_name: tweet.user.screen_name, text: tweet.text, url: tweet[:media][0][:video_info][:variants][0][:url].to_str } if regexp_url.match?(tweet[:media][0][:video_info][:variants][0][:url])
              return content || {}
          end
        end
      end
    end
    return {}
  end
end
