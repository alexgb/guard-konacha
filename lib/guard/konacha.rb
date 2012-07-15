require 'guard'
require 'guard/guard'

module Guard
  class Konacha < Guard

    def initialize(watchers=[], options={})
      super
      @spec_dir = 'spec/javascripts'
    end

    def start
      run_all
    end

    def run_all
      run_konacha
    end

    def run_on_changes(paths)
      run_konacha(paths)
    end

    def run_konacha(paths=[])
      files = paths.map { |p| p.to_s.sub(%r{^#{@spec_dir}/}, '').sub(/(.js\.coffee|\.js|\.coffee)/, '') }
      option = files.empty? ? '' : "SPEC=#{files.join(',')}"
      cmd = "bundle exec rake konacha:run #{option}"

      ::Guard::UI.info "Konacha: #{cmd}"
      result = `bundle exec rake konacha:run #{option}`

      last_line = result.split("\n").last
      examples, failures = last_line.scan(/\d/).map { |s| s.to_i }
      image = failures > 0 ? :failed : :success

      ::Guard::UI.info result
      ::Guard::Notifier.notify(last_line, :title => 'Konacha Specs', :image => image )
    end

  end
end