# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "omnibus-openresty"
  s.version     = "0.1.0"
  s.authors     = ["Brian Akins"]
  s.email       = ["brian.akins@turner.com"]
  s.homepage    = "https://bitbucket.org/vgtf/omnibus-openresty"
  s.summary     = %q{Open Source software for use with Omnibus}
  s.description = %q{Open Source software build descriptions for use with Omnibus}

  s.rubyforge_project = "omnibus-openresty"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "omnibus"
  s.add_runtime_dependency "omnibus-software"
end
