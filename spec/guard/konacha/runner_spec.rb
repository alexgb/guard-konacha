require 'spec_helper'

describe Guard::Konacha::Runner do

  let(:runner) { Guard::Konacha::Runner.new }

  before do
    # Silence Ui.info output
    ::Guard::UI.stub :info => true

    subject.stub(:konacha_running?) { true }
  end

  describe '#initialize' do
    subject { runner.options }

    context 'with default options' do
      it { should eq(Guard::Konacha::Runner::DEFAULT_OPTIONS) }
    end

    context 'with run_all => false' do
      let(:runner) { Guard::Konacha::Runner.new :run_all => false }
      it { should eq(Guard::Konacha::Runner::DEFAULT_OPTIONS.merge(:run_all => false)) }
    end
  end

  describe '.launch_konacha' do
    subject { Guard::Konacha::Runner.new }

    before do
      subject.should_receive(:bundler?).any_number_of_times.and_return(false)
    end

    it "launches spin server with cli options" do
      subject.should_receive(:spawn_konacha).once
      subject.launch_konacha('Start')
    end
  end

  describe '.kill_konacha' do
    it 'not call Process#kill with no spin_id' do
      Process.should_not_receive(:kill)
      subject.kill_konacha
    end
  end

  describe '.run' do
    let(:host) { 'localhost' }
    let(:port) { 3500 }
    let(:konacha_url) { "http://#{host}:#{port}#{path}?mode=runner" }

    let(:failing_result) do
      {
        :examples => 3,
        :failures => 3,
        :pending  => 0,
        :duration => 2.5056
      }
    end

    let(:passing_result) do
      {
        :examples => 2,
        :failures => 0,
        :pending  => 0,
        :duration => 0.3056
      }
    end

    let(:pending_result) do
      {
        :examples => 2,
        :failures => 0,
        :pending  => 2,
        :duration => 2.8
      }
    end

    context 'without arguments' do
      let(:path) { '/' }
      let(:port) { 4000 }
      let(:host) { 'other_host' }
      subject { described_class.new :host => host, :port => port }

      it 'runs all the tests' do
        subject.should_receive(:run_tests).with(konacha_url, nil).and_return passing_result
        ::Guard::UI.should_receive(:info).with('Konacha Running: All tests')
        subject.run
      end
    end

    context 'with arguments' do
      let(:path) { '/model/user_spec' }
      let(:file_path) { 'spec/javascripts/model/user_spec.js.coffee' }

      it 'runs specific tests' do
        subject.should_receive(:run_tests).with(konacha_url, file_path).and_return passing_result
        ::Guard::UI.should_receive(:info).with("Konacha Running: #{file_path}")
        subject.run [file_path]
      end
    end

    it 'aggregates multiple test results' do
      files = [
        'spec/javascripts/model/user_spec.js.coffee',
        'spec/javascripts/model/profile_spec.js.coffee'
      ]
      subject.should_receive(:run_tests).twice.and_return(passing_result, failing_result)
      ::Guard::UI.should_receive(:info).with("Konacha Running: #{files.join(' ')}")
      ::Guard::UI.should_receive(:info).with("5 examples, 3 failures\nin 2.81 seconds")
      subject.run files
    end

    describe 'notifications' do
      subject { described_class.new :notifications => true }

      it 'sends text information to the Guard::Notifier' do
        subject.should_receive(:run_tests).exactly(3).times.and_return(passing_result, pending_result, failing_result)
        ::Guard::Notifier.should_receive(:notify).with(
          "7 examples, 3 failures, 2 pending\nin 5.61 seconds",
          :title => 'Konacha Specs',
          :image => :failed
        )
        subject.run ['a', 'b', 'c']
      end
    end

    describe 'Capybara session' do
      let(:fake_session) { double('capybara session', :visit => true, :status_code => 200) }
      let(:fake_reporter) do
        double('konacha reporter',
               :example_count => 5,
               :failure_count => 2,
               :pending_count => 1,
               :duration => 0.3
              )
      end
      let(:fake_runner) { double('konacha runner', :run => true, :reporter => fake_reporter) }
      subject { described_class.new :driver => :other_driver }

      it 'can be configured to another driver' do
        ::Capybara::Session.should_receive(:new).with(:other_driver).and_return(fake_session)
        ::Konacha::Runner.should_receive(:new).with(fake_session).and_return(fake_runner)
        subject.run
      end
    end
  end

  describe '.run_all' do
    context 'with rspec' do
      it "calls Runner.run with 'spec'" do
        subject.should_receive(:run)
        subject.run_all
      end
    end

    context 'with :run_all set to false' do
      let(:runner) { Guard::Konacha::Runner.new :run_all => false }

      it 'not run all specs' do
        runner.should_not_receive(:run)
        runner.run_all
      end
    end
  end

  describe '.run_tests' do
    let(:status_code) { 200 }
    let(:capybara_session) { double('capybara session', :status_code => status_code, :visit => true) }
    before do
      subject.stub :session => capybara_session
    end

    context 'with missing spec' do
      let(:status_code) { 404 }
      let(:missing_spec) { 'models/missing_spec' }

      it 'aborts the test with a missing result' do
        ::Guard::UI.should_receive(:warning).with("No spec found for: #{missing_spec}")
        ::Konacha::Runner.should_receive(:new).never
        subject.run_tests('dummy url', missing_spec).should eql described_class::EMPTY_RESULT
      end
    end

    context 'with runner raising exception' do
      before do
        subject.instance_variable_set(:@session, 'dummy')
        subject.stub :session => double('capybara session', :status_code => 200, :visit => true)
        ::Guard::UI.stub :error => true
      end

      it 'resets the session' do
        ::Konacha::Runner.should_receive(:new) { throw :error }
        expect { subject.run_tests('dummy url', nil) }.to change { subject.instance_variable_get(:@session) }.from('dummy').to(nil)
      end

      it 'outputs the error to Guard' do
        ::Guard::UI.should_receive(:error).with '#<ArgumentError: uncaught throw :error>'
        ::Konacha::Runner.should_receive(:new) { throw :error }

        subject.run_tests('dummy url', nil)
      end
    end
  end

  describe '.bundler?' do
    before do
      Dir.stub(:pwd).and_return("")
    end

    context 'with no bundler option' do
      subject { Guard::Konacha::Runner.new }

      context 'with Gemfile' do
        before do
          File.should_receive(:exist?).with('/Gemfile').and_return(true)
        end

        it 'return true' do
          subject.send(:bundler?).should be_true
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_receive(:exist?).with('/Gemfile').and_return(false)
        end

        it 'return false' do
          subject.send(:bundler?).should be_false
        end
      end
    end

    context 'with :bundler => false' do
      subject { Guard::Konacha::Runner.new :bundler => false }

      context 'with Gemfile' do
        before do
          File.should_not_receive(:exist?)
        end

        it 'return false' do
          subject.send(:bundler?).should be_false
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_not_receive(:exist?)
        end

        it 'return false' do
          subject.send(:bundler?).should be_false
        end
      end
    end

    context 'with :bundler => true' do
      subject { Guard::Konacha::Runner.new :bundler => true }

      context 'with Gemfile' do
        before do
          File.should_receive(:exist?).with('/Gemfile').and_return(true)
        end

        it 'return true' do
          subject.send(:bundler?).should be_true
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_receive(:exist?).with('/Gemfile').and_return(false)
        end

        it 'return false' do
          subject.send(:bundler?).should be_false
        end
      end
    end
  end
end
