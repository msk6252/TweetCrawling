require 'rubygems'
require 'bundler'
Bundler.require

require 'google/cloud/firestore'
require 'logger' 

module Firestore
  def self.get_data(project_id, collection, credential_json)
    begin
      fs = Google::Cloud::Firestore.new(
        project_id: project_id,
        credentials: credential_json
      )
      return fs.col(collection)
    rescue => e
      Logger.new($stdout).error(e)
    end
  end
end
