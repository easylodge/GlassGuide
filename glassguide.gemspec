# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'glassguide/version'

Gem::Specification.new do |gem|
  gem.name          = "glassguide"
  gem.version       = Glassguide::VERSION
  gem.authors       = ["Shuntyard"]
  gem.email         = ["info@shuntyard.co.za"]
  gem.description   = %q{Vehicle info Au}
  gem.summary       = %q{Vehicle info Au, pricing ect}
  #gem.homepage      = ""

  gem.add_dependency "rubyzip"
  gem.add_dependency 'activesupport'

  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rspec-rails", '~> 3.0.0.beta1'
  # gem.add_development_dependency "factory_girl_rails"
  gem.add_development_dependency 'rails', '~> 4.0.0'

  # gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
