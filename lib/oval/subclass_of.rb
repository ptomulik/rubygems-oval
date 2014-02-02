require 'oval/class_decl_base'

class Oval::SubclassOf < Oval::ClassDeclBase
  def validate(thing, subject = nil)
    unless thing.is_a?(Class) and (thing < self.klass)
      raise Oval::ValueError,
        "Invalid class #{thing.inspect}#{for_subject(subject)}. " +
        "Should be subclass of #{klass.name}"
    end
  end
end
