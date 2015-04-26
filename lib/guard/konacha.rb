require 'guard/compat/plugin'
require 'rails'
require 'konacha'

module Guard
  class Konacha < Plugin

    autoload :Runner, 'guard/konacha/runner'
    autoload :Formatter, 'guard/konacha/formatter'
    autoload :Server, 'guard/konacha/server'

    attr_accessor :runner

    def initialize(options = {})
      super
      @runner = Runner.new(options)
    end

    def start
      runner.start
    end

    def run_all
      runner.run
    end

    def run_on_changes(paths)
      runner.run(paths)
    end
    # for guard 1.0.x and earlier
    alias :run_on_change :run_on_changes

  end
end
