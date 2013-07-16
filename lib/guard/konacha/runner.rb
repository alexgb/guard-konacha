module Guard
  class Konacha
    class Runner

      DEFAULT_OPTIONS = {
        :run_all_on_start => :true,
        :notification => true,
        :rails_environment_file => './config/environment'
      }

      attr_reader :options, :session

      def initialize(options={})
        @options = DEFAULT_OPTIONS.merge(options)

        # Require rails config/environment
        require @options[:rails_environment_file]

        # Custom formatter to handle multiple runs
        @formatter = Formatter.new
        ::Konacha.config.formatters = [@formatter]

        # Reuse session to increase performance
        @session = Capybara::Session.new(::Konacha.driver, Server.new)

        ::Konacha.mode = :runner

        UI.info "Guard::Konacha Initialized"
      end

      def runner
        ::Konacha::Runner.new(session)
      end

      def start
        run if options[:run_all_on_start]
      end

      def run(paths = [''])
        @formatter.reset

        paths.each do |path|
          runner.run konacha_path(path)
        end

        @formatter.write_summary
        notify
      rescue => e
        UI.error(e)
      end

      def notify
        if options[:notification]
          image = @formatter.success? ? :success : :failed
          ::Guard::Notifier.notify(@formatter.summary_line, :title => "Konacha Specs", :image => image)
        end
      end


      private


      def konacha_path(path)
        '/' + path.gsub(/^#{::Konacha.config[:spec_dir]}\/?/, '').gsub(/\.coffee$/, '').gsub(/\.js$/, '')
      end

      def unique_id
        "#{Time.now.to_i}#{rand(100)}"
      end

    end
  end
end
