require 'rubygems'
require 'bundler'
Bundler.require

require './SecretManager.rb'
require './Firestore.rb'

class DuplicateDetect
  def initialize
    secretmanager = SecretManager.new("TwitterCrawling")
    project_id = secretmanager.get_secret("FIRESTORE_PROJECT_ID")
    
    users = []
    Firestore.get_data(project_id, "users", "config.json").get do |user|
      users << user.data[:name]
    end
    puts users.select{ |e| users.count(e) > 1 }.uniq
  end
end
DuplicateDetect.new
