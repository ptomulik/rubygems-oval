require 'spec_helper'
require 'oval/options'

describe Oval::Options do
  context "the class" do
    [
      :validate_decl,
      :validate_option_name_decl,
    ].each do |method|
      it { described_class.should respond_to method }
    end
  end

  context "an instance" do
    let(:subject) { described_class[:decl0] }
    before { described_class.stubs(:validate_decl).once.with(:decl0) }
    [
      :validate,
      :validate_option,
      :validate_option_name,
      :validate_option_value,
    ].each do |method|
      it { should respond_to method }
    end
  end

  describe "#validate" do
    context "validate(:symbol)" do
      let(:subject) { described_class[:decl0] }
      let(:msg) { "Invalid options :symbol of type Symbol. Should be a Hash" }
      before do
        described_class.stubs(:validate_decl).once.with(:decl0)
        subject.stubs(:validate_option).never
      end
      it { expect { subject.validate(:symbol) }.to raise_error Oval::ValueError, msg }
    end
    [
      {},
      {:a => :A},
      {:a => :A, :b => :B},
    ].each do |options|
      context "validate(#{options.inspect},:subj1)" do
        let(:options) { options }
        let(:subject) { described_class[:decl1] }
        before do
          described_class.expects(:validate_decl).once.with(:decl1)
          options.each do |name,value|
            subject.expects(:validate_option).once.with(name, value, :subj1)
          end
        end
        it "should invoke validate_option(key,value,:subj1) for each key,value in #{options.inspect}" do
          expect { subject.validate(options,:subj1) }.to_not raise_error
        end
      end
    end
    context "validate({:a => :A})" do
      let(:subject) { described_class[:decl1] }
      before { described_class.expects(:validate_decl).once.with(:decl1) }
      it "should invoke validate_option(:a,:A,nil) once" do
        subject.expects(:validate_option).once.with(:a, :A, nil)
        expect { subject.validate({:a => :A}) }.to_not raise_error
      end
    end
  end

  describe "#validate_option" do
    before { described_class.expects(:validate_decl).once.with(:decl1) }
    let(:subject) { described_class[:decl1] }
    context "validate_option(:name1,:value1,:subj1)" do
      it "should invoke validate_option_name(name1,:subj1) and validate_option_value(:value,:name1,:subj1) once" do
        subject.expects(:validate_option_name).once.with(:name1,:subj1)
        subject.expects(:validate_option_value).once.with(:value1,:name1,:subj1)
        expect { subject.send(:validate_option,:name1,:value1,:subj1) }.to_not raise_error
      end
    end
    context "validate_option(:name1,:value1)" do
      it "should invoke validate_option_name(name1,nil) and validate_option_value(:value,:name1,nil) once" do
        subject.expects(:validate_option_name).once.with(:name1,nil)
        subject.expects(:validate_option_value).once.with(:value1,:name1,nil)
        expect { subject.send(:validate_option,:name1,:value1) }.to_not raise_error
      end
    end
  end

  describe "#validate_option_name" do
    [
      [
        {:foo => :X, :bar => :Y},
        ":bar and :foo",
        [ :foo, :bar ],
        [ :geez ],
      ],
      [
        {:foo => :X, :bar => :Y, :geez => :Z},
        ":bar, :foo and :geez",
        [ :foo, :bar, :geez ],
        [ :dood ],
      ],
    ].each do |decl, enumerated, valid, invalid|
      context "on Options[#{decl.inspect}]" do
        before { described_class.expects(:validate_decl).once.with(decl) }
        let(:subject) { described_class[decl] }
        let(:msg1) { "Invalid option #{name.inspect}. Allowed options are #{enumerated}"}
        let(:msg2) { "Invalid option #{name.inspect} for subj1. Allowed options are #{enumerated}"}
        valid.each do |name|
          context "validate_option_name(#{name.inspect})" do
            let(:name) { name }
            it { expect { subject.send(:validate_option_name, name) }.to_not raise_error }
          end
        end
        invalid.each do |name|
          context "validate_option_name(#{name.inspect})" do
            let(:name) { name }
            it { expect { subject.send(:validate_option_name, name) }.to raise_error Oval::ValueError, msg1}
          end
          context "validate_option_name(#{name.inspect},'subj1')" do
            let(:name) { name }
            it { expect { subject.send(:validate_option_name, name, 'subj1') }.to raise_error Oval::ValueError, msg2}
          end
        end
      end
    end
  end

  describe "#validate_option_value" do
    [
      [
        {:foo => :X, :bar => :Y},
        [ :V, :bar ],
        [ :V, :Y, nil ],
      ],
      [
        {:foo => :X, :bar => :Y, :geez => :Z},
        [ :V, :geez, 'subj1'],
        [ :V, :Z, 'subj1[:geez]'],
      ],
    ].each do |decl, args, args2|
      context "on Options[#{decl.inspect}]" do
        before { described_class.expects(:validate_decl).once.with(decl) }
        let(:subject) { described_class[decl] }
        context "validate_option_value(#{args.map{|x| x.inspect}.join(', ')})" do
          let(:name) { name }
          it "should invoke self.class.ensure_match(#{args2.map{|x| x.inspect}.join(', ')}) once" do
            described_class.stubs(:ensure_match).once.with(*args2)
            expect { subject.send(:validate_option_value,*args) }.to_not raise_error
          end
        end
      end
    end
  end

  describe "#validate_decl" do
    context "validate_decl({:foo => :F, :bar => 4})" do
      it { expect { described_class.validate_decl({:foo => :F, :bar => 4}) }.to_not raise_error }
    end
    context "validate_decl(:decl1)" do
      let(:msg) { "Invalid declaration :decl1 of type Symbol. Should be a Hash" }
      it { expect { described_class.validate_decl(:decl1) }.to raise_error Oval::DeclError, msg }
    end
    [
      {},
      {:one => 1},
      {:one => 1, :two => "Two"},
      {:one => "One", :two => 2, :three => [1,2,3]}
    ].each do |decl|
      context "validate_decl(#{decl.inspect})" do
        let(:decl) { decl }
        before { decl.keys.each {|key| described_class.expects(:validate_option_name_decl).once.with(key) } }
        it "calls validate_option_name_decl(key) once for each key from #{decl.inspect} " do
          expect { described_class.validate_decl(decl) }.to_not raise_error
        end
      end
    end
  end

  describe "validate_option_name_decl" do
    [ :one, 'two', 3 ].each do |decl|
      context "validate_option_name_decl(#{decl.inspect})" do
        let(:decl) { decl }
        it { expect { described_class.validate_option_name_decl(decl) }.to_not raise_error }
      end
    end
  end


  describe "decl" do
    before { described_class.stubs(:validate_decl) }
    context "new(:decl0).decl" do
      it { described_class.new(:decl0).decl.should be :decl0 }
    end
    context "when @decl == :decl1" do
      let(:subject) { described_class.new(:decl0) }
      before { subject.instance_variable_set(:@decl,:decl1) }
      it { subject.decl.should be :decl1 }
    end
  end

  describe "#decl=" do
    # first, stub validate_decl to create dummy object
    before { described_class.stubs(:validate_decl) }
    let(:subject) { described_class.new(:decl0) }
    context "#decl = :decl1" do
      it "should call self.class.validate_decl(:decl1) once" do
        subject # reference before re-stubbing validate_decl
        described_class.stubs(:validate_decl).never
        described_class.stubs(:validate_decl).once.with(:decl1)
        expect { subject.send(:decl=,:decl1) }.to_not raise_error
      end
      it "should assign @decl = :decl1" do
        subject.send(:decl=, :decl1)
        subject.instance_variable_get(:@decl).should be :decl1
      end
    end
  end
end
