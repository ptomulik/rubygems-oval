module Oval; end

class Oval::DeclError < ArgumentError; end
class Oval::ValueError < ArgumentError; end

class Oval::Base

  def self.ensure_equal(thing, decl, subject = nil)
    unless (decl == Oval::Anything) or (thing == decl)
      raise Oval::ValueError,
        "Invalid value #{thing.inspect}#{for_subject(subject)}. Should be " +
        "equal #{decl.inspect}"
    end
  end

  def self.ensure_match(thing, decl, subject = nil)
    if decl.is_a? Oval::Base
      decl.validate(thing,subject)
    else
      # "terminal symbol"
      ensure_equal(thing, decl, subject)
    end
  end

  def self.it_should(decl)
    if decl.is_a? Oval::Base
      decl.it_should
    elsif decl == Oval::Anything
      Oval::Anything[].it_should
    else
      # "terminal symbol"
      "be equal #{decl.inspect}"
    end
  end

  def self.[](*args)#,subject = default_subject)
    return new(*args)
  end

  def validate(value, subject = nil)
    raise NotImplementedError, "This method should be overwritten by a subclass"
  end

  def it_should()
    raise NotImplementedError, "This method should be overwritten by a subclass"
  end

  def initialize(*args)
  end

  private

  def self.for_subject(subject)
    subject ? " for #{subject}" : ""
  end

  def for_subject(subject)
    self.class.for_subject(subject)
  end

  def self.enumerate(items,op)
    return 'none' if items.empty?
    output = items[0..-2].map{|k| k.inspect}.join(', ')
    output.empty? ? items[0].inspect : [output, items[-1].inspect].join(" #{op} ")
  end

  def enumerate(items,op)
    self.class.enumerate(items,op)
  end

end

require 'oval/anything'
