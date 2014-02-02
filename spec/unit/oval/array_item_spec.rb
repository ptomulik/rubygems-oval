require 'spec_helper.rb'
require 'oval/array_item.rb'

describe Oval::ArrayItem do
  context 'the class' do
    it { described_class.should respond_to :[] }
  end
  context 'an instance' do
    let(:subject) { described_class[:item_decl0] }
    it { should respond_to :validate }
    it { should respond_to :item_decl }
  end

  describe "[]" do
    context "#{described_class.name}[:item_decl0]" do
      it "should == new(:item_decl0)" do
        described_class.stubs(:new).once.with(:item_decl0).returns :ok
        described_class[:item_decl0].should be :ok
      end
    end
  end

  describe "item_decl" do
    let(:subject) { described_class[:item_decl0] }
    context "#{described_class.name}[:item_decl0].item_decl" do
      it { subject.item_decl.should be :item_decl0 }
    end
    context "when @item_decl = :item_decl1" do
      before { subject.instance_variable_set(:@item_decl, :item_decl1) }
      it { subject.item_decl.should be :item_decl1 }
    end
  end

  describe "item_decl=" do
    let(:subject) { described_class[:item_decl0] }
    context "item_decl = :item_decl1" do
      it "should assign @item_decl = :item_decl1" do
        subject.send(:item_decl=, :item_decl1)
        subject.instance_variable_get(:@item_decl).should be :item_decl1
      end
    end
  end

  describe "#validate" do
    let(:subject) { described_class[:item_decl0] }
    context "validate(:item1,0)" do
      it 'should invoke self.class.ensure_match(:item1,:item_decl0,nil) once' do
        described_class.expects(:ensure_match).once.with(:item1,:item_decl0,nil)
        subject.validate(:item1,0)
      end
    end
    context "validate(:item1,0,'foo')" do
      it 'should invoke self.class.ensure_match(:item1,:item_decl0,"foo[0]") once' do
        described_class.expects(:ensure_match).once.with(:item1,:item_decl0,"foo[0]")
        subject.validate(:item1,0,'foo')
      end
    end
  end
end

