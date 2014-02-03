require 'spec_helper'
require 'oval/match'

describe Oval::Match do
  it "should be subclass of Oval::Base" do
    described_class.should < Oval::Base
  end

  context 'the class' do
    it { described_class.should respond_to :[] }
  end

  context 'an instance' do
    let(:subject) { described_class[:re0] }
    before { described_class.stubs(:validate_re).with(:re0) }
    it { should respond_to :validate }
    it { should respond_to :re }
    it { should respond_to :it_should }
  end

  describe "[]" do
    context "#{described_class.name}[:re0]" do
      it "should == new(:re0)" do
        described_class.stubs(:new).once.with(:re0).returns :ok
        described_class[:re0].should be :ok
      end
    end
  end

  describe "re" do
    let(:subject) { described_class[:re0] }
    before { described_class.stubs(:validate_re).with(:re0) }
    context "#{described_class.name}[:re0].re" do
      it { subject.re.should be :re0 }
    end
    context "when @re = :re1" do
      before { subject.instance_variable_set(:@re, :re1) }
      it { subject.re.should be :re1 }
    end
  end

  describe "re=" do
    let(:subject) { described_class[:re0] }
    before { described_class.stubs(:validate_re).with(:re0) }
    context "re = :re1" do
      it "should invoke self.class.validate_re(:re1) once" do
        described_class.expects(:validate_re).once.with(:re1)
        expect { subject.send(:re=, :re1) }.to_not raise_error
      end
      it "should assign @re = :re1" do
        described_class.stubs(:validate_re).with(:re1)
        subject.send(:re=, :re1)
        subject.instance_variable_get(:@re).should be :re1
      end
    end
  end

  describe "validate_re" do
    context "#{described_class.name}.validate_re(:re1)" do
      let(:msg) { "Invalid regular expression :re1. Should be an instance of Regexp" }
      it { expect { described_class.validate_re(:re1) }.to raise_error Oval::DeclError, msg }
    end
    context "#{described_class.name}.validate_re(/^.*$/)" do
      it { expect { described_class.validate_re(/^.*$/) }.to_not raise_error }
    end
  end

  describe "#validate" do
    # Valid
    [
      [/.*/, ['foo']],
      [/.*/, ['foo','subj']],
      [/^[a-z_][a-z0-9_]+/, ['_123a','subj']]
    ].each do |re,args|
      context "#{described_class.name}[#{re.inspect}].validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:re) { re }
        let(:args) { args }
        it { expect { described_class[re].validate(*args) }.to_not raise_error }
      end
    end
    # Validation error
    [
      [ /^[a-z_][a-z0-9_]+/, ['5643'], "Invalid value \"5643\". Should match #{(/^[a-z_][a-z0-9_]+/).inspect}" ],
      [ /^[a-z_][a-z0-9_]+/, ['5643','subj'], "Invalid value \"5643\" for subj. Should match #{(/^[a-z_][a-z0-9_]+/).inspect}" ],
      [ /^[a-z_][a-z0-9_]+/, [nil,'subj'], "Invalid value nil for subj. Should match #{(/^[a-z_][a-z0-9_]+/).inspect}" ]
    ].each do |re,args,msg|
      context "#{described_class.name}[#{re.inspect}].validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:re) { re }
        let(:args) { args }
        let(:msg) { msg }
        it { expect { described_class[re].validate(*args) }.to raise_error Oval::ValueError, msg }
      end
    end
  end

  describe "#it_should" do
    [ //, /^.*$/, /^[a-z_][a-z0-9_]+$/].each do |re|
      context "#{described_class}[#{re.inspect}].it_should" do
        let(:re) { re }
        let(:msg) { "match #{re.inspect}" }
        it { described_class[re].it_should.should == msg }
      end
    end
  end
end
