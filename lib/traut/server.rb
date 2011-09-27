require 'amqp'
require 'systemu'

module Traut

  class Server
    def initialize(amqp, actions, log)
      @amqp = amqp
      @actions = actions
      @log  = log
    end

    def loop
      EventMachine.run do
        AMQP.connect(:host => @amqp[:host]) do |connection|
          @log.info "Connected to AMQP at #{@amqp[:host]}:#{@amqp[:port]}"
          channel  = AMQP::Channel.new(connection)
          exchange = channel.topic("traut", :auto_delete => true)

          @actions.each { |route, script|
            @log.info("Registering #{script} for route #{route}")
            channel.queue("").bind(exchange, :routing_key => route).subscribe do |headers, payload|
              status, stdout, stderr = systemu script, 'stdin' => payload
              if status.exitstatus != 0
                @log.error("[#{script}] exit status: #{status.exitstatus}")
                @log.error("[#{script}] stdout: #{stdout.strip}")
                @log.error("[#{script}] stderr: #{stderr.strip}")
              else
                @log.info("[#{script}] exit status: #{status.exitstatus}")
                @log.info("[#{script}] stdout: #{stdout.strip}")
                @log.info("[#{script}] stderr: #{stderr.strip}")
              end
            end
          }

        end
      end
    end

  end
end
