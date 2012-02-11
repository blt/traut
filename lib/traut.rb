require 'traut/version'
require 'ostruct'
require 'eventmachine'

module Traut
  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :Server,      "#{ROOT}/traut/server"
  autoload :Application, "#{ROOT}/traut/application"

  # Provide the base option sets for all Textme daemons and their
  # defaults.
  def self.defaults
    {
      'config' => './traut.conf',
      'logdir' => './logs/',
      'debug'  => true,
      'ssl'    => {}
    }
  end
end

require "#{Traut::ROOT}/traut/version"
require "#{Traut::ROOT}/traut/spawn"
