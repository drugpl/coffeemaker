# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "coffeemaker/version"

Gem::Specification.new do |s|
  s.name        = "coffeemaker"
  s.version     = Coffeemaker::VERSION
  s.authors     = ["Paweł Pacana"]
  s.email       = ["pawel.pacana@gmail.com"]
  s.homepage    = "http://drug.org.pl/projects/coffeemaker"
  s.summary     = %q{IRC bot, how unexpected!}
  s.description = %q{IRC bot that serves as foundation for greater ideas. "Not Invented Here" applies greatly.}

  s.rubyforge_project = "coffeemaker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "eventmachine", "~> 1.0.0.beta.3"
  s.add_runtime_dependency "activesupport"
end
