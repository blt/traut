require 'yaml'
require 'amqp'

module Traut

  class Application
    def initialize(params)
      @options = params[:options] || raise('parameter :options required')
    end

    # Parse the arguments and run the program. Exit on error.
    def run
      load_options

      @logger = Logger.new File.join( File.expand_path(@options['logdir']), 'traut.log')
      @logger.level = boolean(@options['debug']) ? Logger::DEBUG : Logger::INFO

      ## NOTE: Have to start AMQP connection out here.
      amqp = @options['amqp']

      AMQP.connect(:host => amqp['host'], :port => amqp['port'], :vhost => amqp['vhost'],
        :username => amqp['username'], :password => amqp['password']) do |connection|
        @logger.info "Traut #{Traut::VERSION} started"
        channel  = AMQP::Channel.new(connection)
        exchange = channel.topic(amqp['exchange'] || 'traut')

        Traut::Server.new(:channel => channel, :exchange => exchange,
          :events => @options['events'], :log => @logger).run
      end
    end

    private
    def boolean(string)
      return true if string== true || string =~ (/(true|t|yes|y|1)$/i)
      return false
    end

    def abs(p)
      File.expand_path(p)
    end

    def abs?(p)
      a = abs(p)
      [a, a+'/'].include? p
    end

    def mung_config_path(includedir, config)
      # if includedir is absolute do nothing else
      return includedir if abs?(includedir)
      # else take abs-dirname of config and append includedir
      File.join( abs(File.dirname(config)), includedir )
    end

    def load_options
      YAML.load_file(@options['config']).each {
        |key, value| @options[key] = value
      }
      includedir =  mung_config_path(@options['include'], @options['config'])
      @options['events'] = [] unless @options.has_key? 'events'
      Dir.open(includedir).each do |f|
        ff = File.join(includedir, f)
        @options['events'] += YAML.load_file(ff) if File.file?(ff)
      end
    end

  end
end
