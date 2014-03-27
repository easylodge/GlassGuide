# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'glassguide/version'

Gem::Specification.new do |gem|
  gem.name          = "glassguide"
  gem.version       = Glassguide::VERSION
  gem.authors       = ["Shuntyard"]
  gem.email         = ["jean@shuntyard.co.za"]
  gem.description   = %q{Vehicle info Au}
  gem.summary       = %q{Vehicle info Au, pricing ect}
  #gem.homepage      = ""


  gem.add_dependency "rubyzip"
  # gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
