require 'coffeemaker'

module Coffeemaker
  class Bot
    class Irc
      class Message
        attr_accessor :raw, :prefix, :params

        def initialize(msg = nil)
          @raw = msg
          parse if msg
        end

        def numeric_reply?
          !!numeric_reply
        end

        def numeric_reply
          @numeric_reply ||= @command.match(/^\d\d\d$/)
        end

        def nick
          return unless @prefix
          @nick ||= @prefix[/^(\S+)!/, 1]
        end

        def user
          return unless @prefix
          @user ||= @prefix[/^\S+!(\S+)@/, 1]
        end

        def host
          return unless @prefix
          @host ||= @prefix[/@(\S+)$/, 1]
        end

        def server
          return unless @prefix
          return if @prefix.match(/[@!]/)
          @server ||= @prefix[/^(\S+)/, 1]
        end

        def error?
          !!error
        end

        def error
          return @error if @error
          @error = @command.to_i if numeric_reply? && @command[/[45]\d\d/]
        end

        def channel?
          !!channel
        end

        def channel
          return @channel if @channel
          if regular_command? and params.first.start_with?("#")
            @channel = params.first
          end
        end

        def message
          return @message if @message
          if error?
            @message = error.to_s
          elsif regular_command?
            @message = params.last
          end
        end

        def command
          @command.downcase.to_sym
        end

        private
        def parse
          match = @raw.match(/(^:(\S+) )?(\S+)(.*)/)
          _, @prefix, @command, raw_params = match.captures

          raw_params.strip!
          if match = raw_params.match(/:(.*)/)
            @params = match.pre_match.split(" ")
            @params << match[1]
          else
            @params = raw_params.split(" ")
          end
        end

        def regular_command?
          %w(privmsg join part quit).include? @command.downcase
        end
      end
    end
  end
end
