module Enumerable
  def sum(identity = 0, &block)
    if block_given?
      map(&block).sum(identity)
    else
      inject { |sum, element| sum + element } || identity
    end
  end
end