# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  # Metadata
  s.name        = "rspec-system-puppet"
  s.version     = "1.1.0"
  s.authors     = ["Ken Barber"]
  s.email       = ["ken@bob.sh"]
  s.homepage    = "https://github.com/puppetlabs/rspec-system-puppet"
  s.summary     = "Puppet rspec-system plugin"

  # Manifest
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*_spec.rb`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "resources"]

  # Dependencies
  s.required_ruby_version = '>= 1.8.7'
  s.add_runtime_dependency "rspec-system", '~> 1.5', '>= 1.5.0'
end
