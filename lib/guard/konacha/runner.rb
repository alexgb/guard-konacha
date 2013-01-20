require 'childprocess'
require 'capybara'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'konacha/reporter'
require 'konacha/formatter'
require 'konacha/runner'

module Guard
  class Konacha
    class Runner

      DEFAULT_OPTIONS = {
        :bundler  => true,
        :spec_dir => 'spec/javascripts',
        :run_all  => true,
        :driver   => :selenium,
        :host     => 'localhost',
        :port     => 3500,
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
        UI.info "Konacha Running: #{paths.empty? ? 'All tests' : paths.join(' ')}"

        urls = paths.map { |p| konacha_url(p) }
        urls = [konacha_url] if paths.empty?

        test_results = {
          :examples => 0,
          :failures => 0,
          :pending  => 0,
          :duration => 0
        }

        urls.each do |url|
          individual_result = run_tests(url)

          test_results[:examples] += individual_result[:examples]
          test_results[:failures] += individual_result[:failures]
          test_results[:pending]  += individual_result[:pending]
          test_results[:duration] += individual_result[:duration]
        end


        result_line = "#{test_results[:examples]} examples, #{test_results[:failures]} failures"
        result_line << ", #{test_results[:pending]} pending" if test_results[:pending] > 0
        text = [
          result_line,
          "in #{"%.2f" % test_results[:duration]} seconds"
        ].join "\n"

        UI.info text if urls.length > 1

        if @options[:notification]
          image = test_results[:failures] > 0 ? :failed : :success
          ::Guard::Notifier.notify(text, :title => 'Konacha Specs', :image => image )
        end
      end

      def run_tests(url)
        runner = ::Konacha::Runner.new session
        runner.run url
        return {
          :examples => runner.reporter.example_count,
          :failures => runner.reporter.failure_count,
          :pending  => runner.reporter.pending_count,
          :duration => runner.reporter.duration
        }
      end

      def run_all
        return unless @options[:run_all]
        run
      end

      private

      def konacha_url(path = nil)
        url_path = nil
        url_path = path.gsub(/^#{@options[:spec_dir]}/, '').gsub(/\.coffee$/, '').gsub(/\.js$/, '') unless path.nil?
        "http://#{@options[:host]}:#{@options[:port]}#{url_path || '/'}?mode=runner"
      end

      def session
        UI.info "Starting Konacha-Capybara session using #{@options[:driver]} driver, this can take a few seconds..." if @session.nil?
        @session ||= Capybara::Session.new @options[:driver]
      end

      def spawn_konacha_command
        cmd_parts = []
        cmd_parts << "bundle exec" if bundler?
        cmd_parts << "rake konacha:serve"
        cmd_parts.join(' ')
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
