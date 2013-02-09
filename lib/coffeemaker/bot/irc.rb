require 'coffeemaker/bot'
require 'coffeemaker/bot/irc/connection'
require 'active_support/core_ext/module/delegation'

module Coffeemaker
  class Bot
    class Irc
      attr_accessor :on_message, :on_connect
      attr_reader   :host, :port, :nick, :connection, :logger, :user, :pass
      private       :connection

      delegate :join, :part, :msg, :privmsg, to: :connection

      def initialize(options)
        @host       = options.delete(:irc_host)
        @port       = options.delete(:irc_port)
        @nick       = options.delete(:nick)
        @pass       = options.delete(:pass)
        @user       = options.delete(:user)
        @on_message = options.delete(:on_message)
        @logger     = options.delete(:logger)
        @ssl        = options.delete(:ssl)
      end

      def start
        @connection = EM.connect(@host, @port, Connection) do |c|
          c.host       = @host
          c.port       = @port
          c.pass       = @pass
          c.user       = @user
          c.nick       = @nick
          c.on_message = @on_message
          c.on_connect = @on_connect
          c.logger     = @logger
          c.ssl        = @ssl
        end
      end

      def stop
        @connection.close_connection
      end
    end
  end
end
