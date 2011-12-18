$:.push File.expand_path("../lib", __FILE__)
require "outpost/version"

Gem::Specification.new do |s|
  s.name        = "outpost"
  s.version     = Outpost::VERSION.dup
  s.description = "Simple service monitoring with a clean DSL for configuration."
  s.summary     = "Simple service monitoring with a clean DSL for configuration."
  s.author      = "Vinicius Baggio Fuentes"
  s.email       = "vinibaggio@gmail.com"
  s.homepage    = "http://www.github.com/vinibaggio/outpost"

  s.rubyforge_project = "outpost"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "net-ping"
end
