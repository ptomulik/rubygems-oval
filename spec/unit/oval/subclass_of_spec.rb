require 'spec_helper'
require 'oval/subclass_of'


describe Oval::SubclassOf do
  it "should be subclass of Oval::ClassDeclBase" do
    described_class.should < Oval::ClassDeclBase
  end
  describe "#validate" do
    [
      [Integer,[Fixnum]],
    ].each do |klass,args|
      context "#{described_class.name}[#{klass.name}].validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:klass) { klass }
        let(:args) { args }
        let(:subject) { described_class[klass] }
        it { expect { subject.validate(*args) }.to_not raise_error }
      end
    end
    [
      [Integer,[:foo], "Invalid class :foo. Should be subclass of Integer"],
      [Integer,[String], "Invalid class String. Should be subclass of Integer"],
      [Integer,[String,'foo'], "Invalid class String for foo. Should be subclass of Integer"],
    ].each do |klass,args,msg|
      context "#{described_class.name}[#{klass.name}].validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:klass) { klass }
        let(:args) { args }
        let(:msg) { msg }
        let(:subject) { described_class[klass] }
        it { expect { subject.validate(*args) }.to raise_error Oval::ValueError, msg}
      end
    end
  end
end
