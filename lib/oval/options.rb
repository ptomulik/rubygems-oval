require 'oval/base'

class Oval::Options < Oval::Base
  def validate(options, subject = nil)
    unless options.is_a?(Hash)
      raise Oval::ValueError,
        "Invalid options #{options.inspect} of type #{options.class.name}. " +
        "Should be a Hash"
    end
    options.each {|name, value| validate_option(name, value, subject) }
  end

  def initialize(decl)
    self.decl = decl
  end

  attr_reader :decl

  protected

  def decl=(decl)
    self.class.validate_decl(decl)
    @decl = decl
  end

  def validate_option(name, value, subject = nil)
    validate_option_name(name, subject)
    validate_option_value(value, name, subject)
  end

  def validate_option_name(name, subject = nil)
    unless decl.include?(name)
      allowed = enumerate(decl.keys.sort{|x,y| x.to_s <=> y.to_s}, 'and')
      raise Oval::ValueError,
        "Invalid option #{name.inspect}#{for_subject(subject)}. Allowed " +
        "options are #{allowed}"
    end
  end

  def validate_option_value(value, name, subject = nil)
    subject = "#{subject}[#{name.inspect}]" if subject
    self.class.ensure_match(value, decl[name], subject)
  end

  def self.validate_decl(decl)
    unless decl.is_a?(Hash)
      raise Oval::DeclError,
        "Invalid declaration #{decl.inspect} of type #{decl.class.name}. " +
        "Should be a Hash"
    end
    decl.each {|optname,optdecl| validate_option_name_decl(optname) }
  end

  def self.validate_option_name_decl(optname)
    unless optname.respond_to?(:to_s)
      raise Oval::DeclError,
        "Invalid name #{optname.inspect}. Should be convertible to String"
    end
  end

end
