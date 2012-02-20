require 'systemu'

module Traut
  def self.spawn(params, &block)
    uid = params[:user].nil? ? Process::UID.eid : Etc::getpwnam(params[:user])[:uid]
    gid = params[:group].nil? ? Process::GID.eid : Etc::getgrnam(params[:group])[:gid]
    command = params[:command] || require('parameter :command is required')
    payload = params[:payload]

    s = Spawn.new(params[:logger])
    s.spawn(uid, gid, command, payload, block)
  end

  class Spawn
    def initialize(log)
      @log = log
    end

    def spawn(uid, gid, command, payload, block)
      @log.debug "Running #{command} as #{uid}:#{gid}"
      # Why do I use systemu? Have a look at this:
      ## http://stackoverflow.com/questions/8998097/how-do-i-close-eventmachine-systems-side-of-an-stdin-pipe
      pid = Process.fork do
        begin
          @log.debug("As group #{Process::GID.eid} requesting priv change to #{gid}")
          Process::GID.change_privilege(gid)
          @log.debug("As user #{Process::UID.eid} requesting priv change to #{uid}")
          Process::UID.change_privilege(uid)

          @log.debug("Feeding #{command} stdin '#{payload}'")
          status, stdout, stderr = systemu command, 0=>payload
          block.call(status, stdout, stderr)

          @log.info("#{command} exited with #{status}, stderr #{stderr}")
        rescue => err
          @log.fatal("Caught exception is subprocess")
          @log.fatal(err)
        end
      end
      Process.detach pid

      # If you have an answer for that, consider enabling something like
      # following code, keeping in mind that you need to figure out a way to get
      # stderr back as well.

      # EM.system command, proc{ |p| msg(p, payload) } do |stdout,status|
      #     @log.debug("#{stdout} :: #{status}")
      # end
    end

    private
    def msg(process, m)
      process.send_data(m + "\n")
    end

  end
end
