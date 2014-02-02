require 'oval/class_decl_base'

class Oval::KindOf < Oval::ClassDeclBase
  def validate(object, subject = nil)
    unless object.kind_of?(klass)
      raise Oval::ValueError,
        "Invalid object #{object.inspect} of type #{object.class.name}" +
        "#{for_subject(subject)}. Should be a kind of #{klass.name}"
    end
  end
end
