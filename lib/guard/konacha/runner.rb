module Guard
  class Konacha
    class Runner

      DEFAULT_OPTIONS = {
        :run_all_on_start => true,
        :notification => true,
        :rails_environment_file => './config/environment'
      }

      attr_reader :options, :formatter

      def initialize(options={})
        @options = DEFAULT_OPTIONS.merge(options)

        # Require project's rails environment file to load Konacha
        # configuration
        require_rails_environment
        raise "Konacha not loaded" unless defined? ::Konacha

        # Custom formatter to handle multiple runs
        @formatter = Formatter.new
        ::Konacha.config.formatters = [@formatter]

        # Reusable session to increase performance
        @session = Capybara::Session.new(::Konacha.driver, Server.new)

        ::Konacha.mode = :runner

        UI.info "Guard::Konacha Initialized"
      end

      def start
        run if options[:run_all_on_start]
      end

      def run(paths = [''])
        formatter.reset

        paths.each do |path|
          file_path = konacha_path(path)
          if File.exist?(file_path)
            runner.run file_path
          end
        end

        if formatter.examples.any?
          formatter.write_summary
          notify
        end
      rescue => e
        UI.error(e)
      end


      private


      def require_rails_environment
        if @options[:rails_environment_file]
          require @options[:rails_environment_file]
        else
          dir = '.'
          while File.expand_path(dir) != '/' do
            env_file = File.join(dir, 'config/environment.rb')
            if File.exist?(env_file)
              require File.expand_path(env_file)
              break
            end
            dir = File.join(dir, '..')
          end
        end
      end

      def runner
        ::Konacha::Runner.new(@session)
      end

      def konacha_path(path)
        '/' + path.gsub(/^#{::Konacha.config[:spec_dir]}\/?/, '').gsub(/\.coffee$/, '').gsub(/\.js$/, '')
      end

      def unique_id
        "#{Time.now.to_i}#{rand(100)}"
      end

      def notify
        if options[:notification]
          image = @formatter.success? ? :success : :failed
          ::Guard::Notifier.notify(@formatter.summary_line, :title => "Konacha Specs", :image => image)
        end
      end

    end
  end
end
