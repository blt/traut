# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "traut/version"

Gem::Specification.new do |s|
  s.name        = "traut"
  s.version     = Traut::VERSION
  s.authors     = ["Brian L. Troutwine"]
  s.email       = ["brian@troutwine.us"]
  s.homepage    = "https://github.com/blt/traut"
  s.summary     = %q{Traut is like cron for AMQP events.}
  s.description = %q{Unix cron is a venerable program that turns the passage of time into program invokation. Traut does the same, but using AMQP events to trigger execution. AMQP message payloads are written to the stdin of invoked commands.}

  s.rubyforge_project = "traut"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  ## Someday...
  # s.add_development_dependency "rspec", '~> 2.8.0'
  # s.add_development_dependency 'guard'
  # s.add_development_dependency 'guard-rspec'
  # s.add_development_dependency 'simplecov'

  s.add_runtime_dependency "amqp", '>= 0.8.0'
  s.add_runtime_dependency "systemu", '~> 2.4'
  s.add_runtime_dependency 'json', '~> 1.6.5'

end
