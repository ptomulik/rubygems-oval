require 'spec_helper'
require 'oval/class_decl_base'

describe Oval::ClassDeclBase do
  context "the class" do
    [
      :[],
    ].each do |method|
      it { described_class.should respond_to method }
    end
  end

  context "an instance" do
    let(:subject) { described_class[:klass0] }
    before { described_class.any_instance.stubs(:validate_class) }
    it { should be_kind_of Oval::Base }
    [
      :validate_class,
      :klass,
      :klass=,
    ].each do |method|
      it { should respond_to method }
    end
  end

  describe "#validate_class" do
    let(:subject) { described_class.new(:klass0) }
    before do
      described_class.any_instance.stubs(:validate_class)
      subject
      described_class.any_instance.unstub(:validate_class)
    end
    context "validate_class(:symbol1)" do
      let(:msg) { "Invalid class :symbol1 for ClassDeclBase" }
      it { expect { subject.send(:validate_class,:symbol1) }.to raise_error Oval::DeclError, msg }
    end
    [ Array, String, NilClass ].each do |klass|
      context "validate_class(#{klass.name})" do
        let(:klass) { klass }
        it { expect { subject.send(:validate_class,klass) }.to_not raise_error }
      end
    end
  end

  describe "klass" do
    before { described_class.any_instance.stubs(:validate_class) }
    context "new(:klass0).klass" do
      it { described_class.new(:klass0).klass.should be :klass0 }
    end
    context "when @klass == :klass1" do
      let(:subject) { described_class.new(:klass0) }
      before { subject.instance_variable_set(:@klass,:klass1) }
      it { subject.klass.should be :klass1 }
    end
  end

  describe "#klass=" do
    before { described_class.any_instance.stubs(:validate_class) }
    let(:subject) { described_class.new(:klass0) }
    context "#klass = :klass1" do
      it "should call self.class.validate_class(:klass1) once" do
        subject # reference before re-stubbing validate_class
        subject.stubs(:validate_class).never
        subject.stubs(:validate_class).once.with(:klass1)
        expect { subject.send(:klass=,:klass1) }.to_not raise_error
      end
      it "should assign @klass = :klass1" do
        subject.send(:klass=, :klass1)
        subject.instance_variable_get(:@klass).should be :klass1
      end
    end
  end
end
