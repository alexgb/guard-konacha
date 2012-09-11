# Guard::Konacha

Automatically run your [Konacha](https://github.com/jfirebaugh/konacha) tests through [Guard](https://github.com/guard/guard/).

## Install

Install the gem:

    $ gem install guard-konacha

Or add to your Gemfile:

    gem 'guard-konacha'

## Usage

Add guard definitions to your `Guardfile`

    guard :konacha do
      watch(%r{^spec/javascripts/.+_spec(\.js|\.js\.coffee)})
    end

## Configure

If your specs live outside of `spec/javascripts` then tell Konacha where to find them.

    guard :konacha, :spec_dir => 'spec/front-end' do
      # ...
    end
    
## Development

This is a work in progress and could use some help.

## Contributors

[https://github.com/guard/guard/contributors](https://github.com/alexgb/guard-konacha/graphs/contributors)