require 'coffeemaker/bot/irc'

module Coffeemaker
  class Bot
    attr_reader :irc

    def initialize(options)
      @irc = Irc.new(options)
    end

    def start(&block)
      @irc.start
      block.call(@irc) if block_given?
    end

    def stop
      @irc.stop
    end
  end
end
