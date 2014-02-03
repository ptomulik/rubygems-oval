require 'oval/base'
require 'oval/anything'

class Oval::HashItem < Oval::Base

  def validate(item, i, subject = nil)
    key_subject = subject.nil? ? nil: "#{subject} key"
    val_subject = subject.nil? ? nil: "#{subject}[#{item[0].inspect}]"
    self.class.validate(item[0],key_decl,key_subject)
    self.class.validate(item[1],val_decl,val_subject)
  end

  def it_should
    "be {key => value} where key should #{self.class.it_should(key_decl)} " +
    "and value should #{self.class.it_should(val_decl)}"
  end

  def self.[](item_decl)
    new(item_decl)
  end

  def initialize(item_decl)
    self.item_decl = item_decl
  end

  attr_reader :key_decl
  attr_reader :val_decl

  def self.validate_item_decl(decl)
    unless (decl.is_a?(Hash) and decl.size == 1)
      raise Oval::DeclError, "Invalid item declaration #{decl.inspect}. " +
        "Should be one-element Hash of type { key_decl => value_decl }"
    end
  end

  private

  def item_decl=(decl)
    if decl.is_a?(Oval::Anything) or (decl.is_a?(Class) and decl == Oval::Anything)
      @key_decl, @val_decl = [Oval::Anything[], Oval::Anything[]]
    else
      self.class.validate_item_decl(decl)
      @key_decl, @val_decl = decl.first
    end
  end
end
