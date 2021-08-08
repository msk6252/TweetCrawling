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

  logger.info("====== Twitter Crawling Start =====")
  logger.info("====== #{twitter.day_before} ~ #{twitter.today} =====")
  contents = twitter.get_movies_url
  logger.info("====== Twitter Crawling END =====")

  logger.info("====== WordPress Post Start =====")
  contents.each do |content|
    wordpress.create_article(content)
    wordpress.post_article
  end
  logger.info("====== WordPress Post END =====")
end
