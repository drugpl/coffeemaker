require 'coffeemaker/bot'
require 'eventmachine'
require 'optparse'
require 'logger'

module Coffeemaker
  class Runner
    def initialize(argv)
      @options = default_options
      parse_options!(argv)
      @logger = Logger.new(@options.delete(:logfile))
      @logger.level = @options.delete(:log_level)
      @channels = @options.delete(:channels)
    end

    def start
      EM.run do
        bot = Coffeemaker::Bot.new(@options.merge(:logger => @logger))
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
        user: 'coffeemaker',
        channels: [],
        on_message: Proc.new { |msg| @logger.info(msg) if @logger },
        logfile: STDOUT,
        log_level: Logger::INFO
      }
    end

    def parse_options!(argv)
      OptionParser.new do |option|
        option.default_argv = argv
        option.banner = "Usage: coffeemaker [options]"
        option.on('-n NICK') { |nick| @options[:nick] = nick }
        option.on('-u USER') { |user| @options[:user] = user }
        option.on('-w PASS') { |pass| @options[:pass] = pass }
        option.on('-p PORT', Numeric) { |port| @options[:irc_port] = port }
        option.on('-s HOST') { |host| @options[:irc_host] = host }
        option.on('-c CHANNELS', 'comma-separated list of channels') { |channels| @options[:channels] = channels.split }
        option.on('-l LOG_FILE', 'path to log file') { |logfile| @options[:logfile] = logfile }
        option.on('-d', '--debug') { |debug| @options[:log_level] = Logger::DEBUG }
        option.on('--ssl') { |ssl| @options[:ssl] = true }
        option.on_tail('--help') { puts option; exit }
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
