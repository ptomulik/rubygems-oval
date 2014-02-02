require 'oval/class_decl_base'

class Oval::InstanceOf < Oval::ClassDeclBase
  def validate(object, subject = nil)
    unless object.instance_of?(klass)
      raise Oval::ValueError,
        "Invalid object #{object.inspect} of type #{object.class.name}" +
        "#{for_subject(subject)}. Should be an instance of #{klass.name}"
    end
  end
end
