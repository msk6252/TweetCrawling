require 'rubygems'
require 'bundler'
Bundler.require

require './TwitterCrawling.rb'
require './WordPressPost.rb'
require 'logger'

def lambda_handler(event:, context:)
#def lambda_handler
  twitter = TwitterCrawling.new
  wordpress = WordPressPost.new
  logger = Logger.new($stdout)

  # Get Users From Firestore
  users = twitter.get_users

  return if users.empty?

  # Get URL & Post Article
  users.each do | user |
    content = twitter.get_movies_url(user)
    if !content.empty?
      logger.info("===== Create Article & Post =====")
      logger.info("POST: #{content}")
      wordpress.create_article(content)
      wordpress.post_article
    end
  end
end
