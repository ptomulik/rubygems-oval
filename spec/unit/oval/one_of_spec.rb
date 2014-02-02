require 'spec_helper'
require 'oval/one_of'

describe Oval::OneOf do
  context 'the class' do
    it { described_class.should respond_to :[] }
  end
  context 'an instance' do
    it { should respond_to :validate }
    it { should respond_to :decls }
  end

  describe "[]" do
    [[], [:arg1], [:arg1, :arg2], [:arg1, :arg2, :arg3] ].each do |args|
      context "[#{args.map{|x| x.inspect}.join(', ')}]" do
        let(:args) { args }
        it "should == new(#{args.map{|x| x.inspect}.join(', ')})" do
          described_class.expects(:new).once.with(*args).returns :ok
          described_class[*args].should be :ok
        end
      end
    end
  end

  describe "new" do
    [[], [:arg1], [:arg1, :arg2], [:arg1, :arg2, :arg3] ].each do |args|
      context "new(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:args) { args }
        it "should invoke decls = #{args.inspect}" do
          described_class.any_instance.expects(:decls=).once.with(args)
          expect { described_class.new(*args) }.to_not raise_error
        end
      end
    end
  end

  describe "#validate" do
    [
      [ [:foo ], [:foo] ],
      [ [:foo, :bar], [:bar] ],
      [ [:foo, :bar], [:bar,'subj'] ],
    ].each do |decls,args|
      context "#{described_class}[#{decls.map{|x| x.inspect}.join(', ')}].validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:args) { args }
        let(:subject) { described_class[*decls] }
        it { expect { subject.validate(*args) }.to_not raise_error }
      end
    end
    [
      [ [:foo ], [:bar], "Invalid value :bar" ],
      [ [:foo, :bar], [:geez], "Invalid value :geez" ],
      [ [:foo, :bar], [:geez,'subj'], "Invalid value :geez for subj" ],
    ].each do |decls,args,msg|
      context "#{described_class}[#{decls.map{|x| x.inspect}.join(', ')}].validate(#{args.map{|x| x.inspect}.join(', ')})" do
        let(:args) { args }
        let(:subject) { described_class[*decls] }
        let(:msg) { msg }
        it { expect { subject.validate(*args) }.to raise_error Oval::ValueError, msg }
      end
    end
  end
end
