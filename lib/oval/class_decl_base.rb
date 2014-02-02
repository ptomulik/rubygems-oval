require 'oval/base'
class Oval::ClassDeclBase < Oval::Base
  attr_reader :klass
  def self.[](klass)
    new(klass)
  end

  def initialize(klass)
    self.klass = klass
  end

  protected
  def klass=(k)
    validate_class(k)
    @klass = k
  end

  def self.myname; 'ClassDeclBase'; end

  def validate_class(klass)
    unless klass.is_a?(Class)
      subject = self.class.name.sub(/^.*::/,'')
      raise Oval::DeclError,
        "Invalid class #{klass.inspect}#{for_subject(subject)}"
    end
  end
end
