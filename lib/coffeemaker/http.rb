require 'coffeemaker'
require 'coffeemaker/goliath'

module Coffeemaker
  class HTTP
    class Connection < Goliath::Connection
      attr_accessor :irc
    end

    class Router < Goliath::API
      get '/:channel' do
        run Stream.new
      end
    end

    class Stream < Goliath::API
      def on_close(env)
        env[IRC_CONNECTION].part(env[:channel])
      end

      def response(env)
        env[:channel] = params[:channel]
        env[IRC_CONNECTION].join(env[:channel])

        env[IRC_CONNECTION].on_message = Proc.new do |msg|
          env.stream_send("#{msg.body}\n")
        end
        streaming_response(202, {'X-Stream' => 'Goliath'})
      end
    end

    def initialize(options)
      @host    = options.delete(:http_host)
      @port    = options.delete(:http_port)
      @options = options
    end

    def start(irc_connection)
      Goliath.env = :production
      @http = EM.start_server(@host, @port, Coffeemaker::HTTP::Connection) do |c|
        c.port    = 8080
        c.irc     = irc_connection
        c.status  = {}
        c.config  = {}
        c.options = {}
        c.logger  = Logger.new(STDOUT)
        c.app     = Goliath::Rack::Builder.build(Coffeemaker::HTTP::Router, Coffeemaker::HTTP::Router.new)
        c.api     = Coffeemaker::HTTP::Stream.new
      end
    end

    def stop
      EM.stop_server(@http)
    end
  end
end
