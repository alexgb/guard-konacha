require 'spec_helper'

describe Guard::Konacha::Formatter do

  let(:formatter) { Guard::Konacha::Formatter.new }

  it 'should respond not implemented base class methods' do
    expect(formatter).to respond_to(:dump_summary).with(4).arguments
    expect(formatter).to respond_to(:dump_failures)
    expect(formatter).to respond_to(:dump_pending)
  end

  describe('#reset') do
    it 'should respond to reset' do
      expect(formatter).to respond_to(:reset)
    end
  end

  describe('#write_summary') do
    MockException = Struct.new(:message, :backtrace)
    Example = Struct.new(:full_description, :exception, :metadata, :failed?, :pending?)

    def create_example(options)
      example = Example.new(options[:message], options[:exception], {}, options[:failed?], options[:pending?])

      def example.failed?; self[:failed?]; end
      def example.pending?; self[:pending?]; end
      example
    end

    let(:failure) do
      create_example({
        :message => "Bad",
        :exception => MockException.new("Exception", nil),
        :failed? => true,
        :pending? => false
      })
    end
    let(:success) do
      create_example({
        :message => "Good",
        :failed? => false,
        :pending? => false
      })
    end
    let(:pending) do
      create_example({
        :message => "OK",
        :failed? => false,
        :pending? => true
      })
    end

    let(:io) { double("IO", :tty? => true) }

    before do
      allow(formatter).to receive(:io) { io }
    end

    it 'should examples to output' do
      expect(io).to receive(:write).with("F".red).ordered
      expect(io).to receive(:write).with(".".green).ordered
      expect(io).to receive(:write).with("P".yellow).ordered

      expect(io).to receive(:puts).with(any_args).at_least(:once)

      formatter.example_failed(failure)
      formatter.example_passed(success)
      formatter.example_pending(pending)

      formatter.write_summary
    end
  end

end
