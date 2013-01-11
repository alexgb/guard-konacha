require 'childprocess'

module Guard
  class Konacha
    class Runner

      DEFAULT_OPTIONS = {
        :bundler  => true,
        :spec_dir => 'spec/javascripts',
        :run_all  => true,
        :notification => true
      }

      attr_reader :options

      def initialize(options={})
        @options = DEFAULT_OPTIONS.merge(options)
        UI.info "Guard::Konacha Initialized"
      end

      def launch_konacha(action)
        UI.info "#{action}ing Konacha", :reset => true
        spawn_konacha
      end

      def kill_konacha
        if @process
          @process.stop(5) 
          UI.info "Konacha Stopped", :reset => true
        end
      end

      def run(paths=[])
        UI.info "Konacha Running: #{paths.join(' ')}"
        result = run_command(konacha_command(paths))

        if @options[:notification]
          last_line = result.split("\n").last
          examples, failures = last_line.scan(/\d+/).map { |s| s.to_i }
          image = failures > 0 ? :failed : :success
          ::Guard::Notifier.notify(last_line, :title => 'Konacha Specs', :image => image )
        end
      end

      def run_all
        return unless @options[:run_all]
        run
      end

      private

      def run_command(cmd)
        puts result = `#{cmd}`
        result
      end

      def spawn_konacha_command
        cmd_parts = []
        cmd_parts << "bundle exec" if bundler?
        cmd_parts << "rake konacha:serve"
        cmd_parts.join(' ')
      end

      def konacha_command(paths)
        files = []
        files = paths.map { |p| p.to_s.sub(%r{^#{@options[:spec_dir]}/}, '').sub(/(.js\.coffee|\.js|\.coffee)/, '') }
        option = files.empty? ? '' : "SPEC=#{files.join(',')}"

        cmd_parts = []
        cmd_parts << "bundle exec" if bundler?
        cmd_parts << "rake konacha:run"
        cmd_parts << option
        cmd_parts.join(' ').strip
      end

      def spawn_konacha
        @process = ChildProcess.build(spawn_konacha_command)
        @process.io.inherit! if ::Guard.respond_to?(:options) && ::Guard.options && ::Guard.options[:verbose]
        @process.start
      end

      def bundler?
        @bundler ||= options[:bundler] != false && File.exist?("#{Dir.pwd}/Gemfile")
      end
    end
  end
end
