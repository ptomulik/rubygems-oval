require 'spec_helper'
require 'oval/base'

describe Oval::Base do
  context "the class" do
    [
      :ensure_equal,
      :validate,
      :[],
      :for_subject,
      :enumerate,
    ].each do |method|
      it { described_class.should respond_to method }
    end
  end

  context "an instance" do
    let(:subject) { described_class[:decl0] }
    [
      :validate,
    ].each do |method|
      it { should respond_to method }
    end
  end

  describe "validate" do
    context "validate(:foo,:bar)" do
      it "should invoke ensure_equal(:foo,:bar,nil) once" do
        described_class.expects(:ensure_equal).once.with(:foo,:bar,nil)
        expect { described_class.validate(:foo,:bar) }.to_not raise_error
      end
    end
    context "validate(:foo,:bar,'subj1')" do
      it "should invoke ensure_equal(:foo,:bar,'subj1') once" do
        described_class.expects(:ensure_equal).once.with(:foo,:bar,'subj1')
        expect { described_class.validate(:foo,:bar,'subj1') }.to_not raise_error
      end
    end
    context "validate(:foo,decl)" do
      let(:decl) { described_class[:decl0] }
      it "should invoke decl.validate(:foo,nil) once" do
        decl.expects(:validate).once.with(:foo,nil)
        expect { described_class.validate(:foo,decl) }.to_not raise_error
      end
    end
    context "validate(:foo,decl,'subj1')" do
      let(:decl) { described_class[:decl0] }
      it "should invoke decl.validate(:foo,'subj1') once" do
        decl.expects(:validate).once.with(:foo,'subj1')
        expect { described_class.validate(:foo,decl,'subj1') }.to_not raise_error
      end
    end
  end

  describe "[]" do
    [ [], [:arg1], [:arg1,:arg2] ].each do |args|
      context "[#{args.map{|x| x.inspect}.join(', ')}]" do
        let(:args) { args }
        it "should == new(#{args.map{|x| x.inspect}.join(', ')})" do
          described_class.expects(:new).once.with(*args).returns :ok
          described_class[*args].should be :ok
        end
      end
    end
  end

  describe "#validate" do
    let(:subject) { described_class[:decl0] }
    let(:msg) { "This method should be overwritten by a subclass" }
    [ [], [:arg1,:arg2,:arg3] ].each do |args|
      context "validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:args) { args }
        before { described_class.expects(:validate).never }
        it { expect { subject.validate(*args) }.to raise_error ArgumentError }
      end
    end
    context "validate(:value)" do
      it { expect { subject.validate(:value) }.to raise_error NotImplementedError, msg}
    end
    context "validate(:value,:subj1)" do
      it { expect { subject.validate(:value,:subj1) }.to raise_error NotImplementedError, msg}
    end
  end

  describe "#it_should" do
    let(:subject) { described_class[:decl0] }
    let(:msg) { "This method should be overwritten by a subclass" }
    [ [:arg1], [:arg1,:arg2] ].each do |args|
      context "it_should(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:args) { args }
        before { described_class.expects(:it_should).never }
        it { expect { subject.it_should(*args) }.to raise_error ArgumentError }
      end
    end
    context "it_should" do
      it { expect { subject.it_should }.to raise_error NotImplementedError, msg}
    end
  end

  describe "for_subject" do
    [
      [nil,""],
      ["Subj1", " for Subj1"],
      [:subj, " for subj"],
    ].each do |arg,res|
      context "for_subject(#{arg.inspect})" do
        let(:arg) { arg }
        let(:res) { res }
        it { described_class.send(:for_subject,arg).should == res }
      end
    end
  end

  describe "#for_subject" do
    let(:subject) { described_class.new(:decl0) }
    context "for_subject(:subj1)" do
      it "should == self.class.for_subject(subject)" do
        described_class.expects(:for_subject).once.with(:subj1).returns :ok
        subject.send(:for_subject,:subj1).should be :ok
      end
    end
  end

  describe "enumerate" do
    [
      [[[],'and'],'none'],
      [[['one'],'and'],'"one"'],
      [[['one','two'],'and'],'"one" and "two"'],
      [[['one','two','three'],'and'],'"one", "two" and "three"'],
    ].each do |args,res|
      context "enumerate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:args) { args }
        let(:res) { res }
        it { described_class.send(:enumerate,*args).should == res }
      end
    end
  end

  describe "#enumerate" do
    let(:subject) { described_class.new(:decl0) }
    context "enumerate([],'and')" do
      it "should == self.class.enumerate(subject)" do
        described_class.expects(:enumerate).once.with([],'and').returns :ok
        subject.send(:enumerate,[],'and').should be :ok
      end
    end
  end
end
