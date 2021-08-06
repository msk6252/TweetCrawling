require 'rubygems'
require 'bundler'
Bundler.require

require 'twitter'
require 'time'
require './SecretManager.rb'
require './Firestore.rb'

class TwitterCrawling

  def initialize
    ENV['TZ'] = 'Asia/Tokyo'
    secretmanager = SecretManager.new("TwitterCrawling")

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = secretmanager.get_secret("TWITTER_CONSUMER_KEY")
      config.consumer_secret     = secretmanager.get_secret("TWITTER_CONSUMER_SECRET")
      config.access_token        = secretmanager.get_secret("TWITTER_ACCESS_TOKEN")
      config.access_token_secret = secretmanager.get_secret("TWITTER_ACCESS_TOKEN_SECRET")
    end

    @day_before = (Time.now - 3600 * 24).strftime("%Y-%m-%d")
    @today = Time.now.strftime("%Y-%m-%d")
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

  def get_movies_url
    regexp_url = /https?:\/\/[\S]+\.mp4.*/
    
    contents = []
    
    get_users.each do |user|
      @client.search("from:#{user} since:#{@day_before} until:#{@today}", {result_type: "media", tweet_mode: "extended"}).collect do |tweet|
        if tweet[:media].count > 0
          if tweet[:media][0][:video_info]
            if tweet[:media][0][:video_info][:variants].count > 0
                contents << { user_name: tweet.user.screen_name, text: tweet.text, url: tweet[:media][0][:video_info][:variants][0][:url].to_str } if regexp_url.match?(tweet[:media][0][:video_info][:variants][0][:url])
            end
          end
        end
      end
    end
    return contents
  end
end
