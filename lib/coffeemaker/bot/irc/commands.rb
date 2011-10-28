require 'coffeemaker/bot/irc'

module Coffeemaker
  class Bot
    class Irc
      module Commands
        def join(channel)
          send_command :join, channel
        end

        def part(channel)
          send_command :part, channel
        end

        def message(recipient, text)
          send_command :privmsg, recipient, ":#{text}"
        end
      end
    end
  end
end
