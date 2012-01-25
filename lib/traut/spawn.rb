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
      runas(uid, gid) do
        # Why do I use systemu? Have a look at this:
        ## http://stackoverflow.com/questions/8998097/how-do-i-close-eventmachine-systems-side-of-an-stdin-pipe
        status, stdout, stderr = systemu command, 0=>payload
        block.call(status, stdout, stderr)

        # If you have an answer for that, consider enabling the following code,
        # keeping in mind that you need to figure out a way to get stderr back
        # as well.

        # EM.system command, proc{ |p| msg(p, payload) } do |stdout,status|
        #     @log.debug("#{stdout} :: #{status}")
        # end
      end
    end

    private
    def msg(process, m)
      process.send_data(m + "\n")
    end

    def runas(uid, gid, &block)
      cur_uid = Process::UID.eid
      cur_gid = Process::GID.eid

      begin
        Process::UID.change_privilege(uid)
        Process::GID.change_privilege(gid)
        block.call
      ensure
        Process::UID.change_privilege(cur_uid)
        Process::GID.change_privilege(cur_gid)
      end
    end
  end
end
