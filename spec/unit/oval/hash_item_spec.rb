require 'spec_helper'
require 'oval/hash_item'
require 'oval/instance_of'
require 'oval/kind_of'

describe Oval::HashItem do
  context 'the class' do
    it { described_class.should respond_to :[] }
    it { described_class.should respond_to :validate_item_decl }
  end
  context 'an instance' do
    let(:subject) { described_class[{:key_decl0 => :val_decl0}] }
    it { should respond_to :validate }
    it { should respond_to :key_decl }
    it { should respond_to :val_decl }
    it { subject.private_methods.map{|m| m.is_a?(Symbol) ? m : m.intern}.should include :item_decl= }
  end

  describe "[]" do
    context "#{described_class.name}[{:key_decl0 => :val_decl0}]" do
      it "should == new({:key_decl0 => :val_decl0})" do
        described_class.stubs(:new).once.with({:key_decl0 => :val_decl0}).returns :ok
        described_class[{:key_decl0 => :val_decl0}].should be :ok
      end
    end
  end

  describe "validate_item_decl" do
    [ :foo, [], [:a, :b], {:a => :A, :b => :B}, {}, nil ].each do |decl|
      context "validate_item_decl(#{decl.inspect})" do
        let(:decl) { decl }
        let(:msg) { "Invalid item declaration #{decl.inspect}. Should be one-element Hash of type { key_decl => value_decl }"}
        it { expect { described_class.validate_item_decl(decl) }.to raise_error Oval::DeclError, msg }
      end
    end
    [ {:a => :A}, {Oval::InstanceOf[String] => Oval::KindOf[Symbol] } ].each do |decl|
      context "validate_item_decl(#{decl.inspect})" do
        let(:decl) { decl }
        it { expect { described_class.validate_item_decl(decl) }.to_not raise_error }
      end
    end
  end

  describe "#key_decl" do
    let(:subject) { described_class[{:key_decl0 => :val_decl0}] }
    context "#{described_class.name}[{:key_decl0 => :val_decl0}].key_decl" do
      it { subject.key_decl.should be :key_decl0 }
    end
    context "when @key_decl = :key_decl1" do
      before { subject.instance_variable_set(:@key_decl, :key_decl1) }
      it { subject.key_decl.should be :key_decl1 }
    end
  end

  describe "#val_decl" do
    let(:subject) { described_class[:val_decl0] }
    let(:subject) { described_class[{:key_decl0 => :val_decl0}] }
    context "#{described_class.name}[{:key_decl0 => :val_decl0}].key_decl" do
      it { subject.val_decl.should be :val_decl0 }
    end
    context "when @val_decl = :val_decl1" do
      before { subject.instance_variable_set(:@val_decl, :val_decl1) }
      it { subject.val_decl.should be :val_decl1 }
    end
  end

  describe "#item_decl=" do
    let(:subject) { described_class[:item_decl0] }
    before do
      described_class.any_instance.stubs(:item_decl=).once.with(:item_decl0)
      subject
      described_class.any_instance.unstub(:item_decl=)
    end
    context "item_decl = {:key_decl1 => :val_decl1}" do
      before do
        subject
        described_class.expects(:validate_item_decl).once.with({:key_decl1 => :val_decl1})
        subject.send(:item_decl=, {:key_decl1 => :val_decl1})
      end
      it "should assign @key_decl = :key_decl1" do
        subject.instance_variable_get(:@key_decl).should be :key_decl1
      end
      it "should assign @val_decl = :val_decl1" do
        subject.instance_variable_get(:@val_decl).should be :val_decl1
      end
    end
    context "item_decl = Oval::Anything" do
      it "should not invoke validate_item_decl" do
        described_class.stubs(:validate_item_decl).never
        subject.send(:item_decl=, Oval::Anything)
      end
      it "should assign key_decl=Oval::Anything[]" do
        subject.send(:item_decl=, Oval::Anything)
        subject.key_decl.should be Oval::Anything[]
      end
      it "should assign val_decl=Oval::Anything[]" do
        subject.send(:item_decl=, Oval::Anything)
        subject.val_decl.should be Oval::Anything[]
      end
    end
    context "item_decl = Oval::Anything[]" do
      it "should not invoke validate_item_decl" do
        described_class.stubs(:validate_item_decl).never
        subject.send(:item_decl=, Oval::Anything[])
      end
      it "should assign key_decl=Oval::Anything[]" do
        subject.send(:item_decl=, Oval::Anything[])
        subject.key_decl.should be Oval::Anything[]
      end
      it "should assign val_decl=Oval::Anything[]" do
        subject.send(:item_decl=, Oval::Anything[])
        subject.val_decl.should be Oval::Anything[]
      end
    end
  end

  describe "#validate" do
    # Valid items
    [
      [ {:foo => :bar},[[:foo,:bar], 0] ],
      [ {:foo => :bar},[[:foo,:bar], 0, 'sh'] ],
      [ {Oval::InstanceOf[String] => Oval::InstanceOf[Symbol]},[['foo',:bar], 0, 'hash'] ],
    ].each do |item_decl,args|
      context "#{described_class.name}[#{item_decl.inspect}].validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:subject) { described_class[item_decl] }
        let(:args) { args }
        it { expect { subject.validate(*args) }.to_not raise_error }
      end
    end
    [
      [ {:foo => :bar},[[:geez,:bar], 0], "Invalid value :geez. Should be equal :foo" ],
      [ {:foo => :bar},[[:foo,:geez], 1], "Invalid value :geez. Should be equal :bar" ],
      [ {:foo => :bar},[[:geez,:bar], 0,'hash'], "Invalid value :geez for hash key. Should be equal :foo" ],
      [ {:foo => :bar},[[:foo,:geez], 1,'hash'], "Invalid value :geez for hash[:foo]. Should be equal :bar" ],
      [ {Oval::InstanceOf[String] => Oval::InstanceOf[Symbol]},[[:foo,:bar], 0, 'hash'], "Invalid object :foo of type Symbol for hash key. Should be an instance of String"],
      [ {Oval::InstanceOf[String] => Oval::InstanceOf[Symbol]},[['foo','bar'], 0, 'hash'], "Invalid object \"bar\" of type String for hash[\"foo\"]. Should be an instance of Symbol"],
    ].each do |item_decl,args,msg|
      context "#{described_class.name}[#{item_decl.inspect}].validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:subject) { described_class[item_decl] }
        let(:args) { args }
        let(:msg) { msg }
        it { expect { subject.validate(*args) }.to raise_error Oval::ValueError, msg }
      end
    end
  end
end
