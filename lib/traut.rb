require "traut/version"

module Traut
  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :Runner,             "#{ROOT}/traut/runner"
  autoload :Server,             "#{ROOT}/traut/server"
  autoload :Daemon,             "#{ROOT}/traut/daemon"
end

require "#{Traut::ROOT}/traut/version"
