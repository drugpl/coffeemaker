require 'coffeemaker/bot'
require 'coffeemaker/bot/irc/connection'
require 'active_support/core_ext/module/delegation'

module Coffeemaker
  class Bot
    class Irc
      attr_accessor :on_message
      attr_reader   :host, :port, :nick, :connection
      private       :connection

      delegate :join, :part, :msg, :privmsg, to: :connection

      def initialize(options)
        @host       = options.delete(:irc_host)
        @port       = options.delete(:irc_port)
        @nick       = options.delete(:nick)
        @on_message = options.delete(:on_message)
      end

      def start
        @connection = EM.connect(@host, @port, Connection) do |c|
          c.host       = @host
          c.port       = @port
          c.nick       = @nick
          c.on_message = @on_message
        end
      end

      def stop
        @connection.close_connection
      end
    end
  end
end
