require 'guard'
require 'guard/guard'

module Guard
  class Konacha < Guard

    autoload :Runner, 'guard/konacha/runner'
    attr_accessor :runner

    def initialize(watchers=[], options={})
      super
      @runner = Runner.new(options)
    end

    def start
      runner.kill_konacha
      runner.launch_konacha("Start")
      runner.run_all_on_start
    end

    def reload
      runner.kill_konacha
      runner.launch_konacha("Reload")
    end

    def run_all
      runner.run_all
    end

    def run_on_changes(paths)
      runner.run(paths)
    end
    # for guard 1.0.x and earlier
    alias :run_on_change :run_on_changes

    def stop
      runner.kill_konacha
    end

  end
end
