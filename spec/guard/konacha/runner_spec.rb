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

    it "calls Process#kill with 'INT, pid'" do
      subject.should_receive(:fork).and_return(123)
      subject.send(:spawn_konacha, 'foo')

      Process.should_receive(:kill).with(:INT, 123)
      Process.should_receive(:waitpid).with(123, Process::WNOHANG).and_return(123)
      Process.should_not_receive(:kill).with(:KILL, 123)
      subject.kill_konacha
    end

    it "calls Process#kill with 'KILL, pid' if Process.waitpid returns nil" do
      subject.should_receive(:fork).and_return(123)
      subject.send(:spawn_konacha, 'foo')

      Process.should_receive(:kill).with(:INT, 123)
      Process.should_receive(:waitpid).with(123, Process::WNOHANG).and_return(nil)
      Process.should_receive(:kill).with(:KILL, 123)
      subject.kill_konacha
    end

    it 'calls rescue when Process.waitpid raises Errno::ECHILD' do
      subject.should_receive(:fork).and_return(123)
      subject.send(:spawn_konacha, 'foo')

      Process.should_receive(:kill).with(:INT, 123)
      Process.should_receive(:waitpid).with(123, Process::WNOHANG).and_raise(Errno::ECHILD)
      Process.should_not_receive(:kill).with(:KILL, 123)
      subject.kill_konacha
    end
  end

  describe '.run' do
    context 'with Bundler' do
      before do
        subject.should_receive(:bundler?).and_return(true)
      end

      it 'pushes path to konacha' do
        subject.should_receive(:run_command).with('bundle exec rake konacha:run').and_return(konacha_response)
        subject.run
      end
    end

    context 'without Bundler' do
      before do
        subject.should_receive(:bundler?).and_return(false)
      end

      it 'pushes path to spin' do
        subject.should_receive(:run_command).with('rake konacha:run').and_return(konacha_response)
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

  describe '.spawn_konacha' do
    it 'starts a Konacha::Server' do
      runner.should_receive(:exec).with('bundle exec rake konacha:serve').and_return
      runner.stub(:fork).and_yield

      runner.send(:spawn_konacha, 'bundle exec rake konacha:serve')
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
