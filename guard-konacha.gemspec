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
  s.summary     = 'Guard gem for Konacha'
  s.description = 'Automatically run konacha tests'

  s.add_dependency 'guard',   '~> 1.1'
  s.add_dependency 'konacha', '>= 2.3'
  s.add_dependency 'activesupport', '>= 2.2'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE Readme.md]
  s.require_path = 'lib'

  s.rdoc_options = ["--charset=UTF-8", "--main=README.md", "--exclude='lib|Gemfile'"]
end
