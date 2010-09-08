require 'twitter'

module NineOneOne
  class TwitterNotifier
    attr_accessor :consumer_token
    attr_accessor :consumer_secret
    attr_accessor :access_token
    attr_accessor :access_secret

    def initialize(credentials={})
      @consumer_token = credentials['consumer_token']
      @consumer_secret = credentials['consumer_secret']
      @access_token = credentials['access_token']
      @access_secret = credentials['access_secret']
    end

    def notify(message)
      auth = Twitter::OAuth.new(@consumer_token, @consumer_secret)
      auth.authorize_from_access(@access_token, @access_secret)
      client = Twitter::Base.new(auth)

      begin
        client.update(message[0,140])
      rescue Errno::ECONNRESET
        client.update(message[0,140]) # try one more time
      end
    end
  end
end