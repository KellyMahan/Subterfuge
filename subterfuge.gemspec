# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "subterfuge/version"

Gem::Specification.new do |s|
  s.name        = "Subterfuge"
  s.version     = EventMachine::Subterfuge::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kelly Mahan"]
  s.email       = ["kmahan@kmahan.com"]
  s.homepage    = "http://github.com/kmahan/Subterfuge"
  s.summary     = %q{A library for event driven websocket browsing.}
  s.description = %q{A library for event driven websocket browsing.}

  s.rubyforge_project = "em-websocket"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency("em-websocket", ">= 0.2.0")
  s.add_dependency("json")
end
