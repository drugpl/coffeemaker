require 'coffeemaker/bot'
require 'coffeemaker/bot/irc/connection'
require 'active_support/core_ext/module/delegation'

module Coffeemaker
  class Bot
    class Irc
      attr_reader :connection
      attr_accessor :on_message
      delegate :join, :part, :msg, :privmsg, to: :connection

      def initialize(options)
        @host       = options.delete(:irc_host)
        @port       = options.delete(:irc_port)
        @on_message = options.delete(:on_message)
        @options    = options
      end

      def start
        @connection = EM.connect(@host, @port, Connection) do |c|
          c.host       = @host
          c.port       = @port
          c.on_message = @on_message
          c.options    = @options
        end
      end

      def stop
        @connection.close_connection
      end
    end
  end
end
