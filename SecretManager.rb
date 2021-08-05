require 'logger'
require 'json'

class SecretManager
  def initialize(secret_id)
    @logger = Logger.new($stdout)
    @secret_id = secret_id
  end

  def get_secret(key)
    begin
      secret = `AWS_DEFAULT_REGION=ap-northeast-1 aws secretsmanager get-secret-value --secret-id #{@secret_id}`
      secret_json = JSON.load(secret)['SecretString']
      return JSON.load(secret_json)[key]
    rescue => e
      @logger.error(e)
    end
  end
end
