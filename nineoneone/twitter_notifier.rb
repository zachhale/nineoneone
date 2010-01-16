require 'twitter'

module NineOneOne
  class TwitterNotifier    
    attr_accessor :login
    attr_accessor :password
    
    def initialize(credentials={})
      @login = credentials['login']
      @password = credentials['password']
    end
    
    def notify(message)
      auth = Twitter::HTTPAuth.new(@login, @password)
      client = Twitter::Base.new(auth)
      
      begin
        client.update(message[0,140])
      rescue Errno::ECONNRESET
        client.update(message[0,140]) # try one more time
      end
    end
  end
end