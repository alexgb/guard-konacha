require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, ::Rails.env)

module Dummy
  class Application < ::Rails::Application
    config.assets.enabled = true
  end
end
