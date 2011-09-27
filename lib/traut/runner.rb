require 'optparse'
require 'yaml'
require 'logger'

module Traut
  trap(:INT) { puts; exit }

  # CLI runner. Parse options, run program.
  class Runner
    COMMANDS = %w(start stop restart status)

    attr_accessor :options   # parsed options

    def initialize(argv)
      @argv = argv

      # Default options
      @options = {
        :amqp => {
          :host => 'localhost',
          :port => '5672'
        },
        :logs      => '/var/log/traut.log',
        :config    => '/etc/traut/traut.conf',
        :scripts   => '/usr/local/bin/traut',
        :debug     => false,
        :actions   => nil,
      }

      parse!
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: traut [options]"
        opts.separator ""
        opts.on("-A", "--amqp [HOST]", "The AMQP server host") {
          |host| @options[:amqp_host] = host
        }
        opts.on("-P", "--amqp_port [PORT]", "The AMQP server host port") {
          |port| @options[:amqp_host] = port
        }
        opts.on("-S", "--subscriptions", "The server AMQP subscriptions.") {
          |subscriptions| @options[:subscriptions] = subscriptions || '*'
        }
        opts.on("-C", "--config [FILE]", "Load options from config file") {
          |file| @options[:config] = file
        }
        opts.on("-s", "--scripts", "Location of traut scripts directory") {
          |scripts| @options[:scripts] = scripts
        }
        opts.on('-l', '--logs [LOG]', "Location of log directory location") {
          |log| @options[:logs] = log
        }
        opts.on('--debug', 'Enable debug logging') {
          |debug| @options[:debug] = true
        }
        opts.on_tail("-h", "--help", "Show this message.") do
          puts opts
          exit
        end
        opts.on_tail("-v", "--version", "Show version") {
          puts Traut::VERSION; exit
        }
      end
    end

    # Parse command options out of @argv
    def parse!
      parser.parse! @argv
      @command   = @argv.shift
      @arguments = @argv
    end

    # Parse the arguments and run the program. Exit on error.
    def run!
      load_options_from_config_file!

      log = Logger.new(@options[:logs])
      log.level = @options[:debug] ? Logger::DEBUG : Logger::INFO

      actions = @options[:actions]
      actions = actions.merge(actions) { |k,v|
        File.join(@options[:scripts], v)
      }

      actions.each { |route, script|
        if ! File.exists?(script)
          log.error("#{script} does not exist on disk")
          exit 1
        elsif ! File.executable?(script)
          log.error("#{script} exists on disk but is not executable.")
          exit 1
        else
          log.info("#{script} recognized on disk and executable.")
        end
      }

      server = Server.new(@options[:amqp], actions, log)

      server.loop
    end

    private

    def load_options_from_config_file!
      if file = @options.delete(:config)
        YAML.load_file(file).each {
          |key, value| @options[key.to_sym] = value
        }
      end
    end

  end
end
