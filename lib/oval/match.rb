require 'oval/base'

class Oval::Match < Oval::Base

  def validate(thing, subject = nil)
    begin
      unless re.match(thing)
        raise Oval::ValueError,
          "Invalid value #{thing.inspect}#{for_subject(subject)}. " +
          "Should #{it_should}"
      end
    rescue TypeError => err
      ere = /(?:can't convert|no implicit conversion of) \S+ (?:in)?to String/
      if ere.match(err.message)
        raise Oval::ValueError,
          "Invalid value #{thing.inspect}#{for_subject(subject)}. " +
          "Should #{it_should} but it's not even convertible to String"
      else
        raise
      end
    end
  end

  def it_should
    "match #{re.inspect}"
  end

  def self.[](re)
    new(re)
  end

  def initialize(re)
    self.re = re
  end

  attr_reader :re

  private

  def re=(re)
    self.class.validate_re(re)
    @re = re
  end

  def self.validate_re(re)
    unless re.is_a?(Regexp)
      raise Oval::DeclError, "Invalid regular expression #{re.inspect}. " +
        "Should be an instance of Regexp"
    end
  end
end
