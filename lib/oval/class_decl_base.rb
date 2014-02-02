require 'oval/base'
class Oval::ClassDeclBase < Oval::Base
  def self.[](klass)
    new(klass)
  end

  def initialize(klass)
    self.klass = klass
  end

  attr_reader :klass

  private

  def klass=(klass)
    self.class.validate_class(klass, self.class)
    @klass = klass
  end

  def self.validate_class(klass,receiver)
    unless klass.is_a?(Class)
      subject = receiver.name.sub(/^.*::/,'')
      raise Oval::DeclError,
        "Invalid class #{klass.inspect}#{for_subject(subject)}"
    end
  end
end
