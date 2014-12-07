# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/konacha/version'

Gem::Specification.new do |s|
  s.name        = 'guard-konacha'
  s.version     = Guard::KonachaVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alex Gibbons']
  s.email       = ['alex.gibbons@gmail.com']
  s.homepage    = 'https://github.com/alexgb/guard-konacha'
  s.summary     = 'Guard plugin for Konacha'
  s.description = 'Automatically run konacha tests'
  s.license     = 'MIT'

  s.add_dependency 'guard',   '>= 2.0'
  s.add_dependency('guard-compat', '~> 0.3')
  s.add_dependency 'konacha', '>= 3.0'

  s.add_development_dependency 'rspec', '~> 2.13'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'poltergeist'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE Readme.md]
  s.require_path = 'lib'

  s.rdoc_options = ["--charset=UTF-8", "--main=README.md", "--exclude='lib|Gemfile'"]
end
