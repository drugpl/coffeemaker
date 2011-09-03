require 'goliath/connection'
require 'goliath/api'

module Goliath
  module Constants
    IRC_CONNECTION = 'IRC_CONNECTION'
  end

  class Request
    alias_method :initialize_without_irc, :initialize

    def initialize(app, conn, env)
      initialize_without_irc(app, conn, env)
      env[IRC_CONNECTION] = conn.irc
    end
  end
end

