# Guard::Konacha [![Build Status](https://travis-ci.org/alexgb/guard-konacha.png?branch=master)](https://travis-ci.org/alexgb/guard-konacha)

Automatically run your [Konacha](https://github.com/jfirebaugh/konacha) tests through [Guard](https://github.com/guard/guard/).

## Install

If you haven't already, start by installing and configuring [Konacha](https://github.com/jfirebaugh/konacha). Then add the `guard-konacha` gem to your Gemfile:

    # Gemfile
    gem 'guard-konacha'

And install

    $ bundle install

## Setup

Add the default configurations to your Guardfile.

    $ bundle exec guard init konacha

## Run

And that's it. Your Konacha powered JavaScript tests will now run whenever your JavaScript assets or spec files change.

    $ bundle exec guard

## Additionally

I recommend using the [capybara-webkit](https://github.com/thoughtbot/capybara-webkit) or [poltergeist](https://github.com/jonleighton/poltergeist) drivers rather than the default selenium based driver. See [Konacha instructions](https://github.com/jfirebaugh/konacha#configuration). 

To get system notifications see [Guard instructions](https://github.com/guard/guard/wiki/System-notifications).

## Contributors

[https://github.com/alexgb/guard-konacha/graphs/contributors](https://github.com/alexgb/guard-konacha/graphs/contributors)
