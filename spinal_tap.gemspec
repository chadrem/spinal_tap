# -*- encoding: utf-8 -*-
require File.expand_path('../lib/spinal_tap/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chad Remesch"]
  gem.email         = ["chad@remesch.com"]
  gem.description   = %q{Backdoor into your long running ruby processes.}
  gem.summary       = %q{Spinal tap lets you easily connect into running ruby processes such as daemons and cron scripts.  With great power comes great responsibility.}
  gem.homepage      = "http://github.com/chadrem/spinal_tap"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "spinal_tap"
  gem.require_paths = ["lib"]
  gem.version       = SpinalTap::VERSION

  gem.add_development_dependency('rake', ['= 0.9.2.2'])
  gem.add_development_dependency('rspec', ['= 2.11'])
  gem.add_development_dependency('guard', ['= 1.2.3'])
  gem.add_development_dependency('guard-rspec', ['= 1.2.0'])
  gem.add_development_dependency('growl', ['= 1.0.3'])
  gem.add_development_dependency('debugger', ['>= 1.1.4'])
end
