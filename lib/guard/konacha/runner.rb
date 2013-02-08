require 'net/http'
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
        Capybara.app_host = konacha_base_url
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
        return UI.info("Konacha server not running") unless konacha_running?

        UI.info "Konacha Running: #{paths.empty? ? 'All tests' : paths.join(' ')}"

        urls = paths.map { |p| konacha_url(p) }
        urls = [konacha_url] if paths.empty?

        test_results = {
          :examples => 0,
          :failures => 0,
          :pending  => 0,
          :duration => 0
        }

        urls.each_with_index do |url, index|
          individual_result = run_tests(url, paths[index])

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

      EMPTY_RESULT = {
        :examples => 0,
        :failures => 0,
        :pending  => 0,
        :duration => 0,
      }

      def run_tests(url, path)
        session.reset!
        session.visit url

        if session.status_code == 404
          UI.warning "No spec found for: #{path}"
          return EMPTY_RESULT
        end

        runner = ::Konacha::Runner.new session
        runner.run url
        return {
          :examples => runner.reporter.example_count,
          :failures => runner.reporter.failure_count,
          :pending  => runner.reporter.pending_count,
          :duration => runner.reporter.duration
        }
      rescue => e
        UI.error e.inspect
        @session = nil
      end

      def run_all
        return unless @options[:run_all]
        run
      end

      private

      def konacha_url(path = nil)
        url_path = path.gsub(/^#{@options[:spec_dir]}\/?/, '').gsub(/\.coffee$/, '').gsub(/\.js$/, '') unless path.nil?
        "/#{url_path}?mode=runner&unique=#{unique_id}"
      end

      def unique_id
        "#{Time.now.to_i}#{rand(100)}"
      end

      def session
        UI.info "Starting Konacha-Capybara session using #{@options[:driver]} driver, this can take a few seconds..." if @session.nil?
        @session ||= Capybara::Session.new @options[:driver]
      end

      def spawn_konacha_command
        cmd_parts = ''
        cmd_parts << "bundle exec " if bundler?
        cmd_parts << "rake konacha:serve"
        cmd_parts.split
      end

      def spawn_konacha
        unless @process
          @process = ChildProcess.build(*spawn_konacha_command)
          @process.io.inherit! if ::Guard.respond_to?(:options) && ::Guard.options && ::Guard.options[:verbose]
          @process.start
        end
      end

      def konacha_base_url
        "http://#{@options[:host]}:#{@options[:port]}"
      end

      def konacha_running?
        Net::HTTP.get_response(URI.parse(konacha_base_url))
      rescue Errno::ECONNREFUSED
      end

      def bundler?
        @bundler ||= options[:bundler] != false && File.exist?("#{Dir.pwd}/Gemfile")
      end
    end
  end
end
