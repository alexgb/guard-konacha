# Guard::Konacha [![Build Status](https://travis-ci.org/alexgb/guard-konacha.png)](https://travis-ci.org/alexgb/guard-konacha)

Automatically run your [Konacha](https://github.com/jfirebaugh/konacha) tests through [Guard](https://github.com/guard/guard/).

## Install

Install the gem:

    $ gem install guard-konacha

Or add to your Gemfile:

    gem 'guard-konacha'

## Usage

Add guard definitions to your `Guardfile`

    guard :konacha do
      watch(%r{^app/assets/javascripts/(.*)\.js(\.coffee)?$}) { |m| "#{m[1]}_spec.js" }
      watch(%r{^spec/javascripts/.+_spec(\.js|\.js\.coffee)$})
    end

## Configure

If your specs live outside of `spec/javascripts` then tell Konacha where to find them.

    guard :konacha, :spec_dir => 'spec/front-end' do
      # ...
    end

If you want to use capybara-webkit instead of the default selenium
driver:

    require 'capybara-webkit'

    guard :konacha, :driver => :webkit do
      # ...
    end

If you are running konacha:serve on a different host or port than the
default `localhost` and `3500`, the configuration settings `:host` and `:port` will help you there.

## Development

This is a work in progress and could use some help.

## Contributors

[https://github.com/alexgb/guard-konacha/graphs/contributors](https://github.com/alexgb/guard-konacha/graphs/contributors)
