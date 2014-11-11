require 'spec_helper'

describe Guard::Konacha do
  rails_env_file = File.expand_path('../../dummy/config/environment', __FILE__)
  subject { Guard::Konacha.new(:rails_environment_file => rails_env_file) }

  before do
    # Silence UI.info output
    allow(::Guard::UI).to receive(:info).and_return(true)
  end

  describe '#initialize' do
    it "instantiates Runner with given options" do
      expect(Guard::Konacha::Runner).to receive(:new).with(:rails_environment_file => nil, :spec_dir => 'spec/assets')
      Guard::Konacha.new(:rails_environment_file => nil, :spec_dir => 'spec/assets')
    end
  end

   describe '.start' do
    it "starts Runner" do
      expect(subject.runner).to receive(:start)
      subject.start
    end
  end

  describe '.run_all' do
    it "calls Runner.run" do
      expect(subject.runner).to receive(:run).with(no_args)
      subject.run_all
    end
  end

    describe '.run_on_change (for guard 1.0.x and earlier)' do
    it 'calls Runner.run with file name' do
      expect(subject.runner).to receive(:run).with(['file_name.js'])
      subject.run_on_change(['file_name.js'])
    end
  end

  describe '.run_on_changes' do
    it "calls Runner.run with file name" do
      expect(subject.runner).to receive(:run).with(['file_name.js'])
      subject.run_on_changes(['file_name.js'])
    end

    it "calls Runner.run with paths" do
      expect(subject.runner).to receive(:run).with(['spec/controllers', 'spec/requests'])
      subject.run_on_changes(['spec/controllers', 'spec/requests'])
    end
  end

end
