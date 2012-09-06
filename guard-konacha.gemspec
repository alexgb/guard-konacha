Gem::Specification.new do |s|
  s.name        = 'guard-konacha'
  s.version     = '0.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alex Gibbons']
  s.email       = ['alex.gibbons@gmail.com']
  s.homepage    = 'https://github.com/alexgb/guard-konacha'
  s.summary     = 'Guard gem for Konacha'
  s.description = 'Automatically run konacha tests'

  s.add_dependency 'guard',   '~> 1.1'
  s.add_dependency 'konacha', '~> 1.4'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE Readme.md]
  s.require_path = 'lib'

  s.rdoc_options = ["--charset=UTF-8", "--main=README.md", "--exclude='lib|Gemfile'"]
end
