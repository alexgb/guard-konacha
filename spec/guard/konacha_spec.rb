require 'spec_helper'

describe Guard::Konacha do
  subject { Guard::Konacha.new }

  describe '#initialize' do
    it 'should instantiate with a default spec_dir' do
      subject.instance_variable_get(:@spec_dir).should eq('spec/javascripts')
    end

    it 'accepts a spec_dir option to specify a different spec location' do
      guard = Guard::Konacha.new([], :spec_dir => 'spec/mocha')
      guard.instance_variable_get(:@spec_dir).should eq('spec/mocha')
    end
  end
end
