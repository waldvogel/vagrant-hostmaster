# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vagrant/hostmaster/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["S. Brent Faulkner"]
  gem.email         = ["brent.faulkner@mosaic.com"]
  gem.description   = %q{Vagrant plugin to modify host and guest hostfiles.}
  gem.summary       = %q{Vagrant plugin to modify host and guest hostfiles.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "vagrant-hostmaster"
  gem.require_paths = ["lib"]
  gem.version       = Vagrant::Hostmaster::VERSION

  gem.add_development_dependency('rake')
end
