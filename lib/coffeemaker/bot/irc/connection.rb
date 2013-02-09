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

        attr_accessor :port, :host, :nick, :on_message, :on_connect, :logger, :ssl, :user, :pass

        def connection_completed
          return complete_connection unless @ssl
          start_tls
        end

        def ssl_handshake_completed
          @logger.info "ssl handshake completed"
          complete_connection
        end

        def receive_line(data)
          msg = ::Coffeemaker::Bot::Irc::Message.new(data)
          @logger.debug "received #{data}"

          case msg.command
          when :ping
            send_command :pong
          when :privmsg, :topic, :part, :join
            on_message.call(msg) if on_message
          end
        end

        def unbind
          @logger.info "diconnected"

          @deferred_status = nil
          if @connected or @reconnecting
            EM.add_timer(1) do
              @logger.info "reconnecting"
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
          cmd  = [name.to_s.upcase] + args
          data = "#{cmd.flatten.join(' ')}\r\n"

          @logger.debug "sending #{data}"
          send_data(data)
        end

        def send_command(name, *args)
          callback { _send_command(name, *args) }
        end

        def complete_connection
          @reconnecting = false
          @connected    = true
          @logger.info "connected"

          @logger.info "authenticating"
          _send_command :user, [@user] * 4
          _send_command :pass, @pass if @pass
          _send_command :nick, @nick

          on_connect.call if on_connect
          succeed
        end
      end
    end
  end
end
