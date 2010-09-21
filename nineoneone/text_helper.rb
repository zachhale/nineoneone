module NineOneOne
  module TextHelper
    # stolen from ActiveSupport
    def truncate(text, options={})
      options[:length] ||= 30
      options[:omission] ||= "..."

      if text
        l = options[:length] - options[:omission].length
        (text.length > options[:length] ? text[0...l] + options[:omission] : text).to_s
      end
    end
  end
end