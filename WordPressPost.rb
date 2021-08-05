require 'faraday'
require 'base64'
require 'json'
require 'pp'
require 'logger'
require './SecretManager.rb'

class WordPressPost
  def initialize
    secretmanager = SecretManager.new("TwitterCrawling")
    wordpress_user = secretmanager.get_secret("WORDPRESS_USER")
    wordpress_password = secretmanager.get_secret("WORDPRESS_PASSWORD")
    wordpress_url = secretmanager.get_secret("WORDPRESS_URL")
    @logger = Logger.new($stdout)
    authorization = 'Basic ' + Base64.encode64("#{wordpress_user}:#{wordpress_password}")
    @header = {
      "Content-Type" => "application/json",
      "Authorization" => authorization
    }
    @wp_api_url = wordpress_url
    @data_json = {}.to_json
  end

  def create_article(content)
    url = content[:url]
    text = content[:text]
    @data_json = {
      title: "【タイトル】",
      content: "<h1>【タイトル】</h1><br /><p>#{text}</p><br /><figure class='wp-block-video'><video controls src='#{url}'></video></figure>",
      status: "draft"
    }.to_json

  end

  def post_article
    response = Faraday.post(@wp_api_url, @data_json, @header)
    @logger.info(response)
  end
end
