# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "traut/version"

Gem::Specification.new do |s|
  s.name        = "traut"
  s.version     = Traut::VERSION
  s.authors     = ["Brian L. Troutwine"]
  s.email       = ["brian.troutwine@carepilot.com"]
  s.homepage    = ""
  s.summary     = %q{Turns AMQP events to system command execution}
  s.description = %q{Traut is a configurable daemon for running localhost commands in response to events generated elsewhere. AMQP is used as the interchange. Traut can make application deployments in response to code checkins, automate database failover and anything else that can be scripted. It needs only companions to pump events through the 'traut' exchange.}

  s.rubyforge_project = "traut"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "daemons", '~> 1.1'
  s.add_runtime_dependency "amqp", '>= 0.8.0'
  s.add_runtime_dependency "systemu", '~> 2.4'

end
