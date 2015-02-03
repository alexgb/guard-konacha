ENV['RAILS_ENV'] ||= 'test'

unless ENV['CI']
  require 'simplecov'

  SimpleCov.start do
    add_group 'Guard::Konacha', 'lib/guard'
    add_group 'Specs', 'spec'
  end
end

require 'rspec'
require 'timecop'
require 'guard/konacha'
require 'guard/compat/test/helper'

module Guard
  module UI
    extend self

    def error(*args)
    end
  end
end
