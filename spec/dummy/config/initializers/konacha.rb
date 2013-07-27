require 'capybara/poltergeist'

Konacha.configure do |config|
  config.driver = :poltergeist
end if defined?(Konacha)
