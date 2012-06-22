require 'coffeemaker/bot/irc'
require 'coffeemaker/bot/irc/message'
require 'coffeemaker/bot/irc/commands'
require 'eventmachine'

module Coffeemaker
  class Bot
    class Irc
      module Connection
        class Error < StandardError; end

        include ::EM::Deferrable
        include ::EM::Protocols::LineText2
        include ::Coffeemaker::Bot::Irc::Commands

        attr_accessor :port, :host, :nick, :on_message, :on_connect

        def connection_completed
          @reconnecting = false
          @connected    = true
          _send_command :user, [@nick] * 4
          _send_command :nick, @nick
          on_connect.call if on_connect
          succeed
        end

        def receive_line(data)
          msg = ::Coffeemaker::Bot::Irc::Message.new(data)
          case msg.command
          when :ping
            send_command :pong
          when :privmsg, :topic, :part, :join
            on_message.call(msg) if on_message
          end
        end

        def unbind
          @deferred_status = nil
          if @connected or @reconnecting
            EM.add_timer(1) do
              reconnect(@host, @port)
            end
            @connected    = false
            @reconnecting = true
          else
            raise Error, "unable to connect to server #{@host}:#{@port}"
          end
        end

        private
        def _send_command(name, *args)
          cmd = [name.to_s.upcase] + args
          send_data("#{cmd.flatten.join(' ')}\r\n")
        end

        def send_command(name, *args)
          callback { _send_command(name, *args) }
        end
      end
    end
  end
end
