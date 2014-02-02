require 'spec_helper'
require 'oval/instance_of'

describe Oval::InstanceOf do
  describe 'an instance' do
    let(:subject)  { described_class[:klass] }
    before { described_class.stubs(:validate_class) }
    it { should respond_to :validate }
  end

  context "#{described_class.name}[:symbol1]" do
    let(:subject) { described_class[:symbol1] }
    let(:msg) { "Invalid class :symbol1 for InstanceOf" }
    it { expect { subject }.to raise_error Oval::DeclError, msg }
  end

  describe "#validate" do
    [
      [Array, []],
      [String, "hello"],
      [Fixnum, 1],
    ].each do |klass,object|
      context "#{described_class.name}[#{klass.name}].validate(#{object.inspect})" do
        let(:subject) { described_class[klass] }
        let(:object) { object }
        it { expect { subject.validate(object) }.to_not raise_error }
      end
    end
    [
      [Array, {}],
      [String, :symbol1],
      [Fixnum, "hello"],
      [Integer, 1],
      [Object, :obj]
    ].each do |klass,object|
      context "#{described_class.name}[#{klass.name}].validate(#{object.inspect})" do
        let(:subject) { described_class[klass] }
        let(:object) { object }
        let(:msg) { "Invalid object #{object.inspect} of type #{object.class.name}. Should be an instance of #{klass.name}" }
        it { expect { subject.validate(object) }.to raise_error msg }
      end
    end
  end
end
