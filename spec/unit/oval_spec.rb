require 'spec_helper'
require 'oval'

describe Oval do
  let(:subject) { Class.new { extend Oval; def to_s; 'OvalReceiver'; end } }
  describe "the receiver" do
    let(:subject) { Class.new { extend Oval } }
    it { should respond_to :ov_anything }
    it { should respond_to :ov_collection }
    it { should respond_to :ov_instance_of }
    it { should respond_to :ov_kind_of }
    it { should respond_to :ov_one_of }
    it { should respond_to :ov_options }
    it { should respond_to :ov_subclass_of }
  end

  its(:ov_anything) { should be Oval::Anything }
  its(:ov_collection) { should be Oval::Collection }
  its(:ov_instance_of) { should be Oval::InstanceOf }
  its(:ov_kind_of) { should be Oval::KindOf }
  its(:ov_one_of) { should be Oval::OneOf }
  its(:ov_options) { should be Oval::Options }
  its(:ov_subclass_of) { should be Oval::SubclassOf }
end

# examples from README.md and other sources
describe Oval do
  describe "Example 1" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.foo(ops = {})
          ov_options[ :foo => ov_anything ].validate(ops, 'ops')
        end
      end
    end
    it("should compile"){ subject }
    context "foo" do
      it { expect { subject.foo }.to_not raise_error }
    end
    context "foo :foo => 10" do
      it { expect { subject.foo :foo => 10 }.to_not raise_error }
    end
    context "foo :foo => 10, :bar => 20" do
      let(:msg) { "Invalid option :bar for ops. Allowed options are :foo" }
      it { expect { subject.foo :foo => 10, :bar => 20 }.to raise_error Oval::ValueError, msg}
    end
  end
  describe "Example 2" do
    let(:subject) do
      Class.new do
        extend Oval
        # create a singleton declaration ov
        def self.ov
          @ov ||= ov_options[ :foo => ov_anything ]
        end
        # use ov to validate ops
        def self.foo(ops = {})
          ov.validate(ops, 'ops')
        end
      end
    end
    it("should compile"){ subject }
    context "foo" do
      it { expect { subject.foo }.to_not raise_error }
    end
    context "foo :foo => 10" do
      it { expect { subject.foo :foo => 10 }.to_not raise_error }
    end
    context "foo :foo => 10, :bar => 20" do
      let(:msg) { "Invalid option :bar for ops. Allowed options are :foo" }
      it { expect { subject.foo :foo => 10, :bar => 20 }.to raise_error Oval::ValueError, msg}
    end
  end
end
