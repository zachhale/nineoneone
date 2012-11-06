require 'twitter'

module NineOneOne
  class TwitterNotifier
    include NineOneOne::TextHelper

    attr_accessor :consumer_token
    attr_accessor :consumer_secret
    attr_accessor :access_token
    attr_accessor :access_secret

    def initialize(credentials={})
      @consumer_token = credentials['consumer_token']
      @consumer_secret = credentials['consumer_secret']
      @access_token = credentials['access_token']
      @access_secret = credentials['access_secret']

      Twitter.configure do |config|
        config.consumer_key = @consumer_token
        config.consumer_secret = @consumer_secret
        config.oauth_token = @access_token
        config.oauth_token_secret = @access_secret
      end
    end

    def notify(message)
      message = truncate(message, :length => 140, :omission => '..')

      begin
        Twitter.update(message)
      rescue Errno::ECONNRESET
        Twitter.update(message) # try one more time
      end
    end
  end
end