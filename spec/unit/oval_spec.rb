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
    it { should respond_to :ov_match }
    it { should respond_to :ov_one_of }
    it { should respond_to :ov_options }
    it { should respond_to :ov_subclass_of }
  end

  its(:ov_anything) { should be Oval::Anything }
  its(:ov_collection) { should be Oval::Collection }
  its(:ov_instance_of) { should be Oval::InstanceOf }
  its(:ov_kind_of) { should be Oval::KindOf }
  its(:ov_match) { should be Oval::Match }
  its(:ov_one_of) { should be Oval::OneOf }
  its(:ov_options) { should be Oval::Options }
  its(:ov_subclass_of) { should be Oval::SubclassOf }

  describe "validate" do
    context "#{described_class.name}.validate(:foo,:bar)" do
      it "should invoke Oval::Base.validate(:foo,:bar,nil) once" do
        Oval::Base.expects(:validate).once.with(:foo,:bar,nil)
        expect { described_class.validate(:foo,:bar) }.to_not raise_error
      end
    end
    context "#{described_class.name}.validate(:foo,:bar,'subj')" do
      it "should invoke Oval::Base.validate(:foo,:bar,'subj') once" do
        Oval::Base.expects(:validate).once.with(:foo,:bar,'subj')
        expect { described_class.validate(:foo,:bar,'subj') }.to_not raise_error
      end
    end
  end
end

# examples from README.md and other sources
describe Oval do
  describe "Example 1" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.foo(ops = {})
          Oval.validate(ops, ov_options[ :foo => ov_anything ], 'ops')
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
          Oval.validate(ops, ov, 'ops')
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

  describe "ov_anything example" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.ov
          @oc = ov_options[ :bar => ov_anything ]
        end
        def self.foo(ops = {})
          Oval.validate(ops, ov, 'ops')
        end
      end
    end
    it("should compile"){ subject }
    context "foo" do
      it { expect { subject.foo }.to_not raise_error }
    end
    [ 10, nil, "bar" ].each do |val|
      context "foo :bar => #{val.inspect}" do
        let(:val) { val }
        it { expect { subject.foo :bar => val }.to_not raise_error }
      end
    end
    context "foo :foo => 10, :bar => 20" do
      let(:msg) { "Invalid option :foo for ops. Allowed options are :bar" }
      it { expect { subject.foo :foo => 10, :bar => 20 }.to raise_error Oval::ValueError, msg}
    end
  end

  describe "ov_collection example" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.ov_h
          ov_collection[ Hash, { ov_instance_of[Symbol] => ov_anything } ]
        end
        def self.ov_a
          ov_collection[ Array, ov_instance_of[String] ]
        end
        def self.foo(h, a)
          Oval.validate(h, ov_h, 'h')
          Oval.validate(a, ov_a, 'a')
        end
      end
    end
    it("should compile"){ subject }
    [ 
      [ {:x => 10},  [ 'xxx' ]  ],
      [ {:x => 10, :y => nil}, [ 'xxx', 'zzz' ]  ]
    ].each do |args|
      context "foo(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:args) { args}
        it { expect { subject.foo(*args) }.to_not raise_error }
      end
    end
    context "foo(10,['xxx'])" do
      let(:msg) { "Invalid value Fixnum for h.class. Should be equal Hash" }
      it { expect { subject.foo(10,['xxx']) }.to raise_error Oval::ValueError, msg}
    end
    context "foo({:x => 10, 'y' => 20},['xxx'])" do
      let(:msg) { 'Invalid object "y" of type String for h key. Should be an instance of Symbol' }
      it { expect { subject.foo({:x => 10, 'y' => 20},['xxx']) }.to raise_error Oval::ValueError, msg}
    end
    context "foo({:x => 10},20)" do
      let(:msg) { "Invalid value Fixnum for a.class. Should be equal Array" }
      it { expect { subject.foo({:x => 10}, 20) }.to raise_error Oval::ValueError, msg}
    end
    context "foo({:x => 10},['ten', 20])" do
      let(:msg) { "Invalid object 20 of type Fixnum for a[1]. Should be an instance of String" }
      it { expect { subject.foo({:x => 10}, ['ten', 20]) }.to raise_error Oval::ValueError, msg}
    end
  end

  describe "ov_instance_of example" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.ov
          ov_instance_of[String]
        end
        def self.foo(s)
          Oval.validate(s, ov, 's')
        end
      end
    end
    it("should compile"){ subject }
    context "foo('bar')" do
      it { expect { subject.foo('bar') }.to_not raise_error }
    end
    context "foo(10)" do
      let(:msg) { "Invalid object 10 for s. Should be an instance of String" }
      it { expect { subject.foo('bar') }.to_not raise_error }
    end
  end

  describe "ov_kind_of example" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.ov
          ov_kind_of[Numeric]
        end
        def self.foo(n)
          Oval.validate(n, ov, 'n')
        end
      end
    end
    it("should compile"){ subject }
    context "foo(10)" do
      it { expect { subject.foo(10) }.to_not raise_error }
    end
    context "foo(10.0)" do
      it { expect { subject.foo(10.0) }.to_not raise_error }
    end
    context "foo('10')" do
      let(:msg) { 'Invalid object "10" of type String for n. Should be a kind of Numeric' }
      it { expect { subject.foo('10') }.to raise_error Oval::ValueError, msg}
    end
  end

  describe "ov_match example" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.ov
          # Only valid identifiers are allowed as :bar option
          ov_match[/^[a-z_]\w+$/]
        end
        def self.foo(name)
          Oval.validate(name, ov, 'name')
        end
      end
    end
    it("should compile"){ subject }
    context "foo('var_23')" do
      it { expect { subject.foo('var_23') }.to_not raise_error }
    end
    context "foo(10)" do
      let(:msg) { "Invalid value 10 for name. Should match /^[a-z_]\\w+$/ but it's not even convertible to String" }
      it { expect { subject.foo(10) }.to raise_error Oval::ValueError, msg}
    end
    context "foo('10abc_')" do
      let(:msg) { 'Invalid value "10abc_" for name. Should match /^[a-z_]\\w+$/' }
      it { expect { subject.foo('10abc_') }.to raise_error Oval::ValueError, msg}
    end
  end

  describe "ov_one_of example" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.ov
          ov_one_of[ ov_instance_of[String], ov_kind_of[Numeric], nil ]
        end
        def self.foo(x)
          Oval.validate(x, ov, 'x')
        end
      end
    end
    it("should compile"){ subject }
    context "foo('str')" do
      it { expect { subject.foo('str') }.to_not raise_error }
    end
    context "foo(10)" do
      it { expect { subject.foo(10) }.to_not raise_error }
    end
    context "foo(10.0)" do
      it { expect { subject.foo(10.0) }.to_not raise_error }
    end
    context "foo(nil)" do
      it { expect { subject.foo(nil) }.to_not raise_error }
    end
    context "foo([])" do
      let(:msg) { 'Invalid value [] for x. Should be an instance of String, be a kind of Numeric or be equal nil' }
      it { expect { subject.foo([]) }.to raise_error Oval::ValueError, msg}
    end
  end

  describe "ov_options example" do
    let(:subject) do
      Class.new do
        extend Oval
        def self.ov
          ov_options[ :bar => ov_subclass_of[Numeric] ]
        end
        def self.foo(ops = {})
          Oval.validate(ops, ov, 'ops')
        end
      end
    end
    it("should compile"){ subject }
    context "foo" do
      it { expect { subject.foo }.to_not raise_error }
    end
    context "foo :bar => Integer" do
      it { expect { subject.foo :bar => Integer }.to_not raise_error }
    end
    context "foo :bar => Fixnum" do
      it { expect { subject.foo :bar => Fixnum }.to_not raise_error }
    end
    context "foo([])" do
      let(:msg) { 'Invalid options [] of type Array. Should be a Hash' }
      it { expect { subject.foo([]) }.to raise_error Oval::ValueError, msg}
    end
    context "foo :foo => Fixnum" do
      let(:msg) { 'Invalid option :foo for ops. Allowed options are :bar' }
      it { expect { subject.foo :foo => Fixnum }.to raise_error Oval::ValueError, msg}
    end
    context "foo :bar => 10" do
      let(:msg) { 'Invalid class 10 for ops[:bar]. Should be subclass of Numeric' }
      it { expect { subject.foo :bar => 10 }.to raise_error Oval::ValueError, msg}
    end
  end

end
