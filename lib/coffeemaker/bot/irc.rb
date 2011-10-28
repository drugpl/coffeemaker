require 'coffeemaker/bot'
require 'coffeemaker/bot/irc/connection'
require 'active_support/core_ext/module/delegation'

module Coffeemaker
  class Bot
    class Irc
      include EM::Deferrable

      attr_reader :connection
      delegate :join, :part, :privmsg, to: :connection

      def initialize(options)
        @host     = options.delete(:irc_host)
        @port     = options.delete(:irc_port)
        @callback = options.delete(:on_message)
        @options  = options
      end

      def start
        @connection = EM.connect(@host, @port, Connection) do |c|
          c.host       = @host
          c.port       = @port
          c.on_message = @callback
          c.options    = @options
          c.callback { succeed }
        end
      end

      def stop
        @connection.close_connection
      end
    end
  end
end
