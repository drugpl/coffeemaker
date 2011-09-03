require 'eventmachine'
require 'goliath'
require 'coffeemaker/http'
require 'logger'

module Coffeemaker
  class IRC
    class Error < StandardError; end

    class Message
      attr_accessor :type, :body

      def initialize(type, body)
        @type, @body = type, body
      end
    end

    class Dispatcher
      def parse(line)
        Message.new('UNKNOWN', line)
      end
    end

    module Commands
      def join(channel)
        command("JOIN ##{channel}")
      end

      def part(channel)
        command("PART ##{channel}")
      end
    end

    module Connection
      include EM::Deferrable
      include EM::Protocols::LineText2
      include Commands

      attr_accessor :port, :host, :options, :on_message

      def connection_completed
        @reconnecting = false
        @connected    = true
        succeed
        command("USER", [options[:nick]] * 4)
        command("NICK", options[:nick])
      end

      def receive_line(data)
        msg = Dispatcher.new.parse(data)
        case msg.type
        when 'PONG'
          nil
        else
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
          raise Error, "unable to connect to server (#{@host}, #{@port})"
        end
      end

      private
      def command(*cmd)
        send_data("#{cmd.flatten.join(' ')}\r\n")
      end
    end

    def initialize(options)
      @host    = options.delete(:irc_host)
      @port    = options.delete(:irc_port)
      @options = options
    end

    def start
      @connection = EM.connect(@host, @port, Connection) do |c|
        c.host    = @host
        c.port    = @port
        c.options = @options
      end
    end

    def stop
      @connection.close_connection
    end
  end
end
