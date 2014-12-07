require 'spec_helper'

describe Guard::Konacha do
  rails_env_file = File.expand_path('../../dummy/config/environment', __FILE__)
  let(:options) { {:rails_environment_file => rails_env_file} }
  subject { Guard::Konacha.new(options) }

  before do
    # Silence UI.info output
    ::Guard::UI.stub :info => true
  end

  describe '#initialize' do
    it "instantiates Runner with given options" do
      Guard::Konacha::Runner.should_receive(:new).with(:rails_environment_file => nil, :spec_dir => 'spec/assets')
      Guard::Konacha.new(:rails_environment_file => nil, :spec_dir => 'spec/assets')
    end
  end

   describe '.start' do
    it "starts Runner" do
      subject.runner.should_receive(:start)
      subject.start
    end
  end

  describe '.run_all' do
    it "calls Runner.run" do
      subject.runner.should_receive(:run).with(no_args)
      subject.run_all
    end
  end

    describe '.run_on_change (for guard 1.0.x and earlier)' do
    it 'calls Runner.run with file name' do
      subject.runner.should_receive(:run).with(['file_name.js'])
      subject.run_on_change(['file_name.js'])
    end
  end

  describe '.run_on_changes' do
    it "calls Runner.run with file name" do
      subject.runner.should_receive(:run).with(['file_name.js'])
      subject.run_on_changes(['file_name.js'])
    end

    it "calls Runner.run with paths" do
      subject.runner.should_receive(:run).with(['spec/controllers', 'spec/requests'])
      subject.run_on_changes(['spec/controllers', 'spec/requests'])
    end
  end

end
