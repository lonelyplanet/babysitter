# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'babysitter/version'

Gem::Specification.new do |gem|
  gem.name          = "babysitter"
  gem.version       = Babysitter::VERSION
  gem.authors       = ["Nicolas Overloop", "Paul Grayson", "Andy Roberts", "Mike Wagg"]
  gem.email         = ["noverloop@gmail.com", "paul.grayson@lonelyplanet.com", "coder@onesandthrees.com", "michael@guerillatactics.co.uk"]
  gem.description   = %q{Babysits long-running processes and reports progress or failures}
  gem.summary       = %q{Babysits long-running processes and reports progress or failures}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'fozzie'
  gem.add_dependency 'timecop'
  gem.add_dependency 'aws-sdk'
  gem.add_dependency 'rake'

  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'rspec'

end
