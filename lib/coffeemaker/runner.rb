require 'coffeemaker/bot'
require 'eventmachine'
require 'optparse'
require 'logger'

module Coffeemaker
  class Runner
    def initialize(argv)
      @options = default_options
      parse_options!(argv)

      if logfile = @options.delete(:logfile)
        @logger = Logger.new(logfile =~ /stdout/i ? STDOUT : logfile)
      end
      @channels = @options.delete(:channels)
    end

    def start
      EM.run do
        bot = Coffeemaker::Bot.new(@options)
        bot.start do |irc|
          @channels.each { |channel| irc.join(channel) }
        end

        trap ("INT") do
          bot.stop
          EM.stop
        end
      end
    end

    private
    def default_options
      {
        irc_host: 'localhost',
        irc_port: 6667,
        nick: 'coffeemaker',
        channels: [],
        on_message: Proc.new { |msg| @logger.info(msg) if @logger }
      }
    end

    def parse_options!(argv)
      OptionParser.new do |option|
        option.default_argv = argv
        option.banner = "Usage: coffeemaker [options]"
        option.on('-n NICK') { |nick| @options[:nick] = nick }
        option.on('-p PORT', Numeric) { |port| @options[:irc_port] = port }
        option.on('-s HOST') { |host| @options[:irc_host] = host }
        option.on('-c CHANNELS', 'comma-separated list of channels') { |channels| @options[:channels] = channels.split }
        option.on('-l LOG_FILE', 'path to log file or STDOUT') { |logfile| @options[:logfile] = logfile }
        option.on('--help') { puts option; exit }
        begin
          option.parse!
        rescue OptionParser::RequiredArgument, OptionParser::InvalidOption
          puts option
          exit
        end
      end
    end
  end
end