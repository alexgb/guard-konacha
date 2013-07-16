module Guard
  class Konacha
    class Formatter < ::Konacha::Formatter

      def initialize
        super($stdout)
      end

      def reset
        io.puts ""
        @examples = []
      end

      def dump_summary(duration, example_count, failure_count, pending_count); end
      def dump_failures; end
      def dump_pending; end

      def success?
        failed_examples.empty?
      end

      def failed_examples
        @examples.select(&:failed?).select(&:exception)
      end

      def pending_examples
        @examples.select(&:pending?)
      end

      def summary_line
        "#{examples.size} examples, #{failed_examples.size} failed, #{pending_examples.size} pending"
      end

      def write_summary
        io.puts ""
        write_failed_examples
        write_pending_examples
        io.puts ""
        io.puts summary_line
      end

      def write_failed_examples
        examples = failed_examples
        unless examples.empty?
          io.puts examples.map { |e| failure_message(e) }.join("\n\n")
        end
      end

      def write_pending_examples
        examples = pending_examples
        unless examples.empty?
          io.puts examples.map { |e| pending_message(e) }.join("\n\n")
        end
      end

    end
  end
end