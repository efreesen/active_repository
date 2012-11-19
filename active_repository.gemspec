# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_repository/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Caio Torres"]
  gem.email         = ["efreesen@gmail.com"]
  gem.description   = %q{An implementation of repository pattern that can connect with any ORM}
  gem.summary       = %q{An implementation of repository pattern that can connect with any ORM}
  gem.homepage      = "http://github.com/efreesen/active_repository"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = "active_repository"
  gem.require_paths = ["lib"]
  gem.version       = ActiveRepository::VERSION

  gem.add_runtime_dependency(%q<active_hash>, [">= 0.9.12"])
  gem.add_runtime_dependency(%q<activemodel>, [">= 3.2.6"])
  gem.add_development_dependency(%q<rspec>, [">= 2.2.0"])
  gem.add_development_dependency(%q<activerecord>)
  gem.add_development_dependency(%q<mongoid>)
  gem.add_development_dependency('rake')
  gem.add_development_dependency(%q<sqlite3>) unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency(%q<jdbc-sqlite3>)  if RUBY_PLATFORM == 'java'
  gem.add_development_dependency(%q<jruby-openssl>)  if RUBY_PLATFORM == 'java'
  gem.add_development_dependency(%q<activerecord-jdbcsqlite3-adapter>)  if RUBY_PLATFORM == 'java'
end
