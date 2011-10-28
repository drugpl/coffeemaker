require 'coffeemaker/bot/irc'

module Coffeemaker
  class Bot
    def initialize(options)
      @irc = Irc.new(options)
    end

    def start(&block)
      @irc.start.callback do
        block.call(@irc) if block_given?
      end
    end

    def stop
      @irc.stop
    end
  end
end
