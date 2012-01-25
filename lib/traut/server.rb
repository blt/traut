require 'json'
require 'systemu'

module Traut

  class Server
    def initialize(params)
      @channel = params[:channel] || raise('parameter :channel required')
      @exchange = params[:exchange] || raise('parameter :exchange required')
      @events = params[:events] || raise('parameter :events required')
      @log = params[:log] || raise('parameter :log required')
    end

    # :: () -> ()
    def run
      subscribe('#') do |headers, payload|
        @log.debug("Noted the reception of message with route '#{headers.routing_key}'.")
      end

      @events.each do |event|
        route, script, user, group = event['event'], event['command'], event['user'], event['group']
        @log.debug("Registering #{script} to run as #{user}:#{group} for event #{route}")

        subscribe(route) do |headers, payload|
          Traut.spawn(:user => user, :group => group, :command => script,
            :payload => payload, :logger => @log) do |status, stdout, stderr|
            condition = 0 == status.exitstatus ? :debug : :error
            result = {:exitstatus => status.exitstatus, :stdout => stdout.strip, :stderr => stderr.strip}
            @log.send(condition, "[#{script}] #{result}")
            publish(result.to_json, headers.routing_key)
          end
        end # channel.queue

      end # eventmap.each
    end # run

    private

    # :: string -> string
    def finished_route(key)
      [key, 'exited'].join('.')
    end

    def publish(msg, route)
      @exchange.publish msg, :routing_key => finished_route(route)
    end

    def subscribe(route, &block)
      @channel.queue('').bind(@exchange, :routing_key => route).subscribe(&block)
    end

  end # Server

end
