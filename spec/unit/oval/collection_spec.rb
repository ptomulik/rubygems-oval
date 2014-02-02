require 'spec_helper'
require 'oval/collection'
require 'oval/one_of'
require 'oval/instance_of'
require 'oval/kind_of'

describe Oval::Collection do
  describe 'the class' do
    it { described_class.should respond_to :[] }
    it { described_class.should respond_to :new }
    it { described_class.should respond_to :validate_class_decl }
  end
  describe 'an instance' do
    let(:subject)  { described_class[Array,nil] }
    it { should respond_to :validate }
    it { should respond_to :class_decl }
    it { should respond_to :item_decl }
  end

  describe "[]" do
    context "[]" do
      it { expect { described_class[] }.to raise_error ArgumentError, /wrong number of arguments / }
    end
    context "[:arg1,:arg2,:arg3]" do
      it { expect { described_class[:arg1,:arg2,:arg3] }.to raise_error ArgumentError, /wrong number of arguments / }
    end
    context "[:arg1]" do
      it "should == new(:arg1,Oval::Anything[])" do
        described_class.expects(:new).once.with(:arg1,Oval::Anything[]).returns :ok
        described_class[:arg1].should be :ok
      end
    end
    context "[:arg1,:arg2]" do
      it "should == new(:arg1,:arg2)" do
        described_class.expects(:new).once.with(:arg1,:arg2).returns :ok
        described_class[:arg1,:arg2].should be :ok
      end
    end
  end

  describe "new" do
    context "new(:arg1,:arg2)" do
      it "should assign self.class_decl=:arg1 and self.item_decl=:arg2 in seqence" do
        seq = sequence('assignments')
        described_class.any_instance.expects(:class_decl=).once.with(:arg1).in_sequence(seq)
        described_class.any_instance.expects(:item_decl=).once.with(:arg2).in_sequence(seq)
        expect { described_class.new(:arg1,:arg2) }.to_not raise_error
      end
    end
  end

  describe "validate_class_decl" do
    [
      [Array, "Array"],
      [Hash, "Hash" ],
      [Class.new(Array), "Class.new(Array)" ],
      [Class.new(Hash), "Class.new(Hash)" ],
      [Oval::SubclassOf[Array], "Oval::SubclassOf[Array]" ],
      [Oval::SubclassOf[Hash], "Oval::SubclassOf[Hash]" ],
      [Oval::SubclassOf[Class.new(Array)], "Oval::SubclassOf[Class.new(Array)]" ],
      [Oval::SubclassOf[Class.new(Hash)], "Oval::SubclassOf[Class.new(Hash)]" ],
    ].each do |decl,desc|
      context "validate_class_decl(#{desc})" do
        let(:decl) { decl }
        it { expect { described_class.validate_class_decl(decl) }.to_not raise_error }
      end
    end
    [ 'a', nil, 0, {}, [] ].each do |decl|
      context "validate_class_decl(#{decl.inspect})" do
        let(:decl) { decl }
        let(:msg) { "Invalid collection class declarator #{decl.inspect}. Should be a (subclass of) Hash or Array" }
        it { expect { described_class.validate_class_decl(decl) }.to raise_error Oval::DeclError, msg }
      end
    end
  end

##  describe "validate_item_decl" do
##    [
##      [Hash, "Hash"],
##      [Class.new(Hash), "Class.new(Hash)" ],
##    ].each do |class_decl,class_desc|
##      context "validate_item_decl(:decl1, #{class_desc})" do
##        let(:class_decl) { class_decl }
##        it "should invoke validate_hash_item_decl(:decl1) once" do
##          described_class.stubs(:validate_hash_item_decl).once.with(:decl1)
##          expect { described_class.validate_item_decl(:decl1,class_decl) }.to_not raise_error
##        end
##      end
##    end
##    [
##      [Array, "Array"],
##      [Class.new(Array), "Class.new(Array)" ],
##    ].each do |class_decl,class_desc|
##      context "validate_item_decl(:decl1, #{class_desc})" do
##        let(:class_decl) { class_decl }
##        it "should not invoke validate_hash_item_decl(:decl1)" do
##          described_class.stubs(:validate_hash_item_decl).never
##          expect { described_class.validate_item_decl(:decl1,class_decl) }.to_not raise_error
##        end
##      end
##    end
##  end

  describe "#class_decl" do
    before do
      described_class.stubs(:validate_class_decl)
      described_class.any_instance.stubs(:item_decl=)
    end
    context "new(:class_decl0,:item_decl0).class_decl" do
      it { described_class.new(:class_decl0,:item_decl0).class_decl.should be :class_decl0 }
    end
    context "when @class_decl == :class_decl1" do
      let(:subject) { described_class.new(:class_decl0) }
      before { subject.instance_variable_set(:@class_decl,:class_decl1) }
      it { subject.class_decl.should be :class_decl1 }
    end
  end

  describe "#class_decl=" do
    before do
      described_class.stubs(:validate_class_decl)
      described_class.any_instance.stubs(:item_decl=)
    end
    let(:subject) { described_class.new(:class_decl0,:item_decl0) }
    context "#class_decl = :class_decl1" do
      it "should call self.class.validate_class_decl(:class_decl1) once" do
        subject # reference before re-stubbing validate_class_decl
        described_class.stubs(:validate_class_decl).never
        described_class.stubs(:validate_class_decl).once.with(:class_decl1)
        expect { subject.send(:class_decl=,:class_decl1) }.to_not raise_error
      end
      it "should assign @class_decl = :class_decl1" do
        subject.send(:class_decl=, :class_decl1)
        subject.instance_variable_get(:@class_decl).should be :class_decl1
      end
    end
  end

  describe "#item_decl" do
    before do
      described_class.any_instance.stubs(:class_decl=)
      described_class.any_instance.stubs(:bind_item_validator)
    end
    context "new(:class_decl0, :item_decl0).item_decl" do
      it { described_class.new(:class_decl0,:item_decl0).item_decl.should be :item_decl0 }
    end
    context "when @item_decl == :item_decl1" do
      let(:subject) { described_class.new(:item_decl0) }
      before { subject.instance_variable_set(:@item_decl,:item_decl1) }
      it { subject.item_decl.should be :item_decl1 }
    end
  end

  describe "#item_decl=" do
    let(:subject) { described_class.new(:class_decl0,:item_decl0) }
    before do
      described_class.any_instance.stubs(:class_decl=)
      described_class.any_instance.stubs(:bind_item_validator)
    end
    context "#item_decl = :item_decl1" do
      it "should call bind_item_validator(:item_decl1) once" do
        subject.expects(:bind_item_validator).once.with(:item_decl1)
        expect { subject.send(:item_decl=,:item_decl1) }.to_not raise_error
      end
      it "should assign @item_decl = :item_decl1" do
        subject.send(:item_decl=, :item_decl1)
        subject.instance_variable_get(:@item_decl).should be :item_decl1
      end
    end
  end

  describe "#select_item_validator" do
    before do
      described_class.any_instance.stubs(:class_decl=).once.with(:class_decl0)
      described_class.any_instance.stubs(:item_decl=).once.with(:item_decl0)
    end
    let(:subject) { described_class.new(:class_decl0,:item_decl0) }
    [
      [Hash, 'Hash'],
      [Class.new(Hash), 'Class.new(Hash)'],
    ].each do |klass,desc|
      context "when #klass == #{desc}" do
        before { subject.stubs(:klass).with().returns(klass) }
        it { subject.send(:select_item_validator).should be Oval::HashItem }
      end
    end
    [
      [Array, 'Array'],
      [Class.new(Array), 'Class.new(Array)'],
    ].each do |klass,desc|
      context "when #klass == #{desc}" do
        before { subject.stubs(:klass).with().returns(klass) }
        it { subject.send(:select_item_validator).should be Oval::ArrayItem }
      end
    end
    [ String, Fixnum, 1, nil, 0 ].each do |klass|
      context "when #klass == #{klass.inspect}" do
        before { subject.stubs(:klass).with().returns(klass) }
        let(:msg) { "Invalid class #{klass.inspect} assigned to klass. It seems like we have a bug in #{described_class.name}" }
        it { expect { subject.send(:select_item_validator) }.to raise_error RuntimeError, msg }
      end
    end
  end

  describe "#validate" do
    class HashSubclass < Hash; end
    class ArraySubclass < Array; end
    # Valid collections
    [
      #
      # Hash
      #
      ["Hash", Hash, Oval::Anything[], {:foo => :FOO}],
      ["Hash", Hash, Oval::Anything, {:foo => :FOO}],
      ["Hash", Hash, {Oval::Anything => Oval::Anything}, {:foo => :FOO}],
      ["HashSubclass", HashSubclass, {Oval::Anything => Oval::Anything}, HashSubclass[{:foo => :FOO}]],
      ["Oval::SubclassOf[Hash]", Oval::SubclassOf[Hash], {Oval::Anything => Oval::Anything}, HashSubclass[{:foo => :FOO}]],

      ["Hash", Hash, {Oval::InstanceOf[Symbol] => Oval::InstanceOf[Symbol]}, {:foo => :FOO}],
      ["Hash", Hash, {Oval::InstanceOf[String] => Oval::KindOf[Fixnum]}, {'one' => 1, 'two' => 2}],
      #
      # Array
      #
      ["Array", Array, Oval::Anything[], [:foo, :bar]],
      ["Array", Array, Oval::Anything, [:foo,:bar]],
      ["ArraySubclass", ArraySubclass, Oval::Anything, ArraySubclass[:foo,:bar]],
      ["Oval::SubclassOf[Array]", Oval::SubclassOf[Array], Oval::Anything, ArraySubclass[:foo, :bar]],
    ].each do |class_desc,class_decl,item_decl,collection|
      context "#{described_class.name}[#{class_desc},#{item_decl.inspect}].validate(#{collection.inspect},'collection')" do
        let(:subject) { described_class[class_decl, item_decl] }
        let(:collection) { collection}
        it { expect { subject.validate(collection,'collection') }.to_not raise_error }
      end
    end
    # Invalid collections
    [
      ["Hash", Hash, {Oval::Anything => Oval::Anything}, :symbol, 'Invalid value Symbol for collection.class. Should be equal Hash'],
      ["Hash", Hash, {Oval::Anything => Oval::Anything}, [], 'Invalid value Array for collection.class. Should be equal Hash'],
      ["HashSubclass", HashSubclass, {Oval::Anything => Oval::Anything}, [], 'Invalid value Array for collection.class. Should be equal HashSubclass'],
      ["HashSubclass", HashSubclass, {Oval::Anything => Oval::Anything}, {:foo => :FOO}, 'Invalid value Hash for collection.class. Should be equal HashSubclass'],
      ["Array", Array, Oval::Anything, :symbol, 'Invalid value Symbol for collection.class. Should be equal Array'],
      ["Array", Array, Oval::Anything, {}, 'Invalid value Hash for collection.class. Should be equal Array'],
      ["ArraySubclass", ArraySubclass, Oval::Anything, {:foo => :FOO}, 'Invalid value Hash for collection.class. Should be equal ArraySubclass'],
      ["ArraySubclass", ArraySubclass, Oval::Anything, [:foo, :bar], 'Invalid value Array for collection.class. Should be equal ArraySubclass'],
      ["Hash", Hash, {Oval::InstanceOf[Symbol] => Oval::InstanceOf[Symbol]}, {:foo => :FOO, 'bar' => :BAR}, "Invalid object \"bar\" of type String for collection key. Should be an instance of Symbol"],
      ["Hash", Hash, {Oval::InstanceOf[String] => Oval::KindOf[Fixnum]}, {'one' => 1, 'two' => :TWO}, "Invalid object :TWO of type Symbol for collection[\"two\"]. Should be a kind of Fixnum"],
      ["Array", Array, Oval::InstanceOf[String], ['one', :two], "Invalid object :two of type Symbol for collection[1]. Should be an instance of String"],
    ].each do |class_desc,class_decl,item_decl, collection, msg|
      context "#{described_class.name}[#{class_desc},#{item_decl.inspect}].validate(#{collection.inspect},'collection')" do
        let(:subject) { described_class[class_decl, item_decl] }
        let(:collection) { collection }
        let(:msg) { msg }
        it { expect { subject.validate(collection,'collection') }.to raise_error Oval::ValueError, msg}
      end
    end
  end
end
