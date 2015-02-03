require 'spec_helper'

describe Guard::Konacha::Runner do

  let(:rails_env_file) { File.expand_path('../../../dummy/config/environment', __FILE__) }
  let(:runner_options) { { :rails_environment_file => rails_env_file } }
  let(:runner) { Guard::Konacha::Runner.new runner_options }

  before do
    # Silence Ui.info output
    allow(::Guard::UI).to receive(:info).and_return(true)
  end

  describe '#initialize' do
    it 'should have default options and allow overrides' do
      expect(runner.options).to eq(Guard::Konacha::Runner::DEFAULT_OPTIONS.merge(runner_options))
    end

    it 'should set Konacha mode to runner' do
      expect(::Konacha.mode).to eq(:runner)
    end
  end

  describe '#start' do
    describe 'with run_all_on_start set to true' do
      let(:runner_options) { super().merge(:run_all_on_start => true) }
      it 'should run all if :run_all_on_start option set to true' do
        expect(runner).to receive(:run).with(no_args)
        runner.start
      end
    end

    describe 'with run_all_on_start set to false' do
      let(:runner_options) { super().merge(:run_all_on_start => false) }
      it 'should run all if :run_all_on_start option set to true' do
        expect(runner).not_to receive(:run)
        runner.start
      end
    end
  end

  describe '#run' do
    let(:konacha_runner) { double("konacha runner") }
    let(:konacha_formatter) { double("konacha formatter") }

    before do
      allow(runner).to receive(:runner) { konacha_runner }
      allow(konacha_formatter).to receive(:any?) { true }
    end

    it 'should run each path through runner and format results' do
      allow(File).to receive(:exists?) { true }
      allow(runner).to receive(:formatter) { konacha_formatter }
      expect(konacha_formatter).to receive(:reset)
      expect(konacha_runner).to receive(:run).with('/1')
      expect(konacha_runner).to receive(:run).with('/foo/bar')
      expect(konacha_formatter).to receive(:write_summary)
      runner.run(['spec/javascripts/1.js', 'spec/javascripts/foo/bar.js'])
    end

    it 'should run each path with a valid extension' do
      expect(File).to receive(:exists?).with(::Rails.root.join('spec/javascripts/1.js').to_s).and_return(true)
      expect(File).to receive(:exists?).with(::Rails.root.join('spec/javascripts/foo/bar.js.coffee').to_s).and_return(true)
      expect(konacha_runner).to receive(:run).with('/1')
      expect(konacha_runner).to receive(:run).with('/foo/bar')
      runner.run(['spec/javascripts/1.js', 'spec/javascripts/foo/bar.js.coffee'])
    end

    it 'should run when called with no arguemnts' do
      allow(runner).to receive(:formatter) { konacha_formatter }
      expect(konacha_formatter).to receive(:write_summary)
      expect(konacha_formatter).to receive(:reset)
      expect(konacha_runner).to receive(:run)
      runner.run
    end
  end

end
