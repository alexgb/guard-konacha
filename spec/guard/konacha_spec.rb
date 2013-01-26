require 'spec_helper'

describe Guard::Konacha do
  subject { Guard::Konacha.new }

  before do
    # Silence UI.info output
    ::Guard::UI.stub :info => true
  end

  describe '#initialize' do
    it "instantiates Runner with given options" do
      Guard::Konacha::Runner.should_receive(:new).with(:spec_dir => 'spec/assets')
      Guard::Konacha.new [], { :spec_dir => 'spec/assets' }
    end
  end

   describe '.start' do
    it "calls Runner.kill_spin and Runner.launch_spin with 'Start'" do
      subject.runner.should_receive(:kill_konacha)
      subject.runner.should_receive(:launch_konacha).with('Start')
      subject.start
    end
  end

  describe '.reload' do
    it "calls Runner.kill_spin and Runner.launch_spin with 'Reload'" do
      subject.runner.should_receive(:kill_konacha)
      subject.runner.should_receive(:launch_konacha).with('Reload')
      subject.reload
    end
  end

  describe '.run_all' do
    it "calls Runner.run_all" do
      subject.runner.should_receive(:run_all)
      subject.run_all
    end
  end

    describe '.run_on_change (for guard 1.0.x and earlier)' do
    it 'calls Runner.run with file name' do
      subject.runner.should_receive(:run).with('file_name.js')
      subject.run_on_change('file_name.js')
    end
  end

  describe '.run_on_changes' do
    it "calls Runner.run with file name" do
      subject.runner.should_receive(:run).with('file_name.js')
      subject.run_on_changes('file_name.js')
    end

    it "calls Runner.run with paths" do
      subject.runner.should_receive(:run).with(['spec/controllers', 'spec/requests'])
      subject.run_on_changes(['spec/controllers', 'spec/requests'])
    end
  end

  describe '.stop' do
    it 'calls Runner.kill_spin' do
      subject.runner.should_receive(:kill_konacha)
      subject.stop
    end
  end
end
