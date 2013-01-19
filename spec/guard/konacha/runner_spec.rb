require 'spec_helper'

describe Guard::Konacha::Runner do
  let(:konacha_response) { "Finished in 6 seconds\n5 examples, 0 failures, 0 pending" }
  let(:runner) { Guard::Konacha::Runner.new }

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
        subject.should_receive(:run_tests).with(konacha_url).and_return passing_result
        ::Guard::UI.should_receive(:info).with('Konacha Running: All tests')
        subject.run
      end
    end

    context 'with arguments' do
      let(:path) { '/model/user_spec' }
      let(:file_path) { 'spec/javascripts/model/user_spec.js.coffee' }

      it 'runs all the tests' do
        subject.should_receive(:run_tests).with(konacha_url).and_return passing_result
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
      let(:fake_session) { double('capybara session') }
      let(:fake_reporter) do
        double('konacha reporter',
               :example_count => 5,
               :failure_count => 2,
               :pending_count => 1,
               :duration => 0.3
              )
      end
      let(:fake_runner) { double('konacha runner', :run => true, :reporter => fake_reporter) }

      it 'can be configured to another driver' do
        instance = described_class.new :driver => :other_driver
        ::Capybara::Session.should_receive(:new).with(:other_driver).and_return(fake_session)
        ::Konacha::Runner.should_receive(:new).with(fake_session).and_return(fake_runner)
        instance.run
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
