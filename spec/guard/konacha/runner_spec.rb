require 'spec_helper'

describe Guard::Konacha::Runner do

  let(:rails_env_file) { File.expand_path('../../../dummy/config/environment', __FILE__) }
  let(:runner_options) { { :rails_environment_file => rails_env_file } }
  let(:runner) { Guard::Konacha::Runner.new runner_options }

  before do
    # Silence Ui.info output
    ::Guard::UI.stub :info => true
    ::Guard::Notifier.stub :notify => true
  end

  describe '#initialize' do
    it 'should have default options and allow overrides' do
      runner.options.should eq(Guard::Konacha::Runner::DEFAULT_OPTIONS.merge(runner_options))
    end

    it 'should set Konacha mode to runner' do
      ::Konacha.mode.should eq(:runner)
    end
  end

  describe '#start' do
    describe 'with run_all_on_start set to true' do
      let(:runner_options) { super().merge(:run_all_on_start => true) }
      it 'should run all if :run_all_on_start option set to true' do
        runner.should_receive(:run).with(no_args)
        runner.start
      end
    end

    describe 'with run_all_on_start set to false' do
      let(:runner_options) { super().merge(:run_all_on_start => false) }
      it 'should run all if :run_all_on_start option set to true' do
        runner.should_not_receive(:run)
        runner.start
      end
    end
  end

  describe '#run' do
    let(:konacha_runner) { double("konacha runner") }
    let(:konacha_formatter) { double("konacha formatter") }

    before do
      runner.stub(:runner) { konacha_runner }
      konacha_formatter.stub(:any?) { true }
    end

    it 'should run each path through runner and format results' do
      File.stub(:exists?) { true }
      runner.stub(:formatter) { konacha_formatter }
      konacha_formatter.should_receive(:reset)
      konacha_runner.should_receive(:run).with('/1')
      konacha_runner.should_receive(:run).with('/foo/bar')
      konacha_formatter.should_receive(:write_summary)
      runner.run(['spec/javascripts/1.js', 'spec/javascripts/foo/bar.js'])
    end

    it 'should run each path with a valid extension' do
      File.should_receive(:exists?).with(::Rails.root.join('spec/javascripts/1.js').to_s).and_return(true)
      File.should_receive(:exists?).with(::Rails.root.join('spec/javascripts/foo/bar.js.coffee').to_s).and_return(true)
      konacha_runner.should_receive(:run).with('/1')
      konacha_runner.should_receive(:run).with('/foo/bar')
      runner.run(['spec/javascripts/1.js', 'spec/javascripts/foo/bar.js.coffee'])
    end

    it 'should run when called with no arguemnts' do
      runner.stub(:formatter) { konacha_formatter }
      konacha_formatter.should_receive(:write_summary)
      konacha_formatter.should_receive(:reset)
      konacha_runner.should_receive(:run)
      runner.run
    end
  end

end
