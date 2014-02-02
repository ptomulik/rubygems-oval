require 'spec_helper'
require 'oval/anything'
describe Oval::Anything do
  let(:subject) { described_class.instance }
  context 'the class' do
    it { described_class.should respond_to :instance }
    it { described_class.should respond_to :[] }
    it { described_class.should_not respond_to :new }
  end
  context 'an instance' do
    it { should respond_to :validate }
  end
  describe "instance (i.e. class method called instance)" do
    it "should return singleton" do
      previous = described_class.instance
      described_class.instance.should be previous
    end
  end
  describe "[]" do
    it "should == #{described_class}.instance" do
      described_class.stubs(:instance).once.with().returns :ok
      described_class[].should be :ok
    end
  end
  describe "#validate" do
    # It should accept anything, which is quite hard to test, so I put here
    # some random stuff ...
    [
      :symbol, nil, 1, 2.1, '', Array, NilClass, Object, Module,
      Class.new, /regex/
    ].each do |x|
      context "validate(#{x.inspect})" do
        let(:x) { x }
        it { expect { subject.validate(x) }.to_not raise_error }
      end
    end
  end
end
