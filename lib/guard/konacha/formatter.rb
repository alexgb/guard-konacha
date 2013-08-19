# -*- encoding : utf-8 -*-
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

      def write_summary
        io.puts ""
        io.puts [
          failed_examples_message,
          pending_examples_message
        ].reject(&:empty?).join("\n\n")
        io.puts ""
        io.puts summary_line
      end

      def summary_line
        "#{examples.size} examples, #{failed_examples.size} failed, #{pending_examples.size} pending"
      end


      private


      def failed_examples
        @examples.select(&:failed?).select(&:exception)
      end

      def pending_examples
        @examples.select(&:pending?)
      end

      def failed_examples_message
        failed_examples.map { |e| failure_message(e) }.join("\n\n")
      end

      def failure_message(example)
        "  \xE2\x9C\x96 ".red + "#{example.metadata['path']}\n" + super
      end

      def pending_examples_message
        pending_examples.map { |e| pending_message(e) }.join("\n\n")
      end

      def pending_message(example)
        "  \xE2\x97\x8B ".yellow + "#{example.metadata['path']}\n" + super
      end

    end
  end
end