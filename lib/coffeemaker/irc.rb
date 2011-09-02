require 'eventmachine'

module Coffeemaker
  class IRC
    class Error < StandardError; end

    module Connection
      include EM::Deferrable
      include EM::Protocols::LineText2

      attr_accessor :port, :host, :options

      def command(*cmd)
        send_data("#{cmd.flatten.join(' ')}\r\n")
      end

      def connection_completed
        @reconnecting = false
        @connected    = true
        succeed
        command("USER", [options[:nick]] * 4)
        command("NICK", options[:nick])
      end

      def receive_line(data)
        puts data
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
    end

    def initialize(options)
      @host    = options.delete(:host)
      @port    = options.delete(:port)
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
      EM.stop
    end
  end
end
