# -*- encoding : utf-8 -*-
unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_group 'Guard::Konacha', 'lib/guard'
    add_group 'Specs', 'spec'
  end
end

require 'rspec'
require 'timecop'
require 'guard/compat/test/helper'
require 'guard/konacha'

ENV["GUARD_ENV"] = 'test'
