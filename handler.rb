require './TwitterCrawling.rb'
require './WordPressPost.rb'

def lambda_handler(event:, context:)
  #def lambda_handler
  twitter = TwitterCrawling.new
  wordpress = WordPressPost.new

  contents = twitter.get_movies_url
  
  contents.each do |content|
    wordpress.create_article(content)
    wordpress.post_article
  end
end
