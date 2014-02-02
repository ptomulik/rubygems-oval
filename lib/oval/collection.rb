require 'oval/base'
require 'oval/anything'
require 'oval/subclass_of'
require 'oval/array_item'
require 'oval/hash_item'

# Declare container (e.g. array or hash).
#
# **Example 1**: Desclare array of arbitrary elements:
#
# ```ruby
# Collection[Array]
# ```
#
# or
#
# ```ruby
# Collection[Array,Anything[]]
# ```
#
# or
#
# ```ruby
# Collection[InstanceOf[Array],Anything[]]
# ```
#
# **Example 2**: Declare Array of Strings:
#
# ```ruby
# Collection[Array,InstanceOf[String]]
# ```
#
# **Example 3**: Desclare any Hash:
#
# ```ruby
# Collection[Hash]
# ```
#
# **Example 4**: Desclare Hash with Symbol keys and Fixnum values
#
# ```ruby
# Collection[Hash,{Symbol => Fixnum}]
# ```
#
class Oval::Collection < Oval::Base

  def validate(collection, subject = nil)
    class_subject = subject.nil? ? nil : "#{subject}.class"
    self.class.ensure_match(collection.class, class_decl, class_subject)
    i = 0
    collection.each { |item| item_validator.validate(item, i, subject); i+= 1}
  end

  def self.[](class_decl,item_decl = Oval::Anything[])
    new(class_decl,item_decl)
  end

  def initialize(class_decl, item_decl = Oval::Anything[])
    self.class_decl = class_decl
    self.item_decl = item_decl
  end

  def self.klass(class_decl)
    class_decl.is_a?(Oval::SubclassOf) ? class_decl.klass : class_decl
  end

  def klass
    self.class.klass(class_decl)
  end

  attr_reader :class_decl
  attr_reader :item_decl
  attr_reader :class_validator
  attr_reader :item_validator

  protected

  def class_decl=(decl)
    self.class.validate_class_decl(decl)
    @class_decl = decl
  end

  def item_decl=(decl)
    bind_item_validator(decl)
    @item_decl = decl
  end

  def bind_item_validator(item_decl)
    @item_validator = select_item_validator[item_decl]
  end

  def select_class_validator
    if klass.is_a?(Class) and klass <= Hash
      Oval::HashClass
    elsif klass.is_a?(Class) and klass <= Array
      Oval::ArrayClass
    else
      # well, we also may have klass that is not a class, but I'm too lazy to
      # handle all possible exceptions,
      raise RuntimeError, "Invalid class #{klass.inspect} assigned to klass. " +
        "It seems like we have a bug in #{self.class.name}"
    end
  end

  def select_item_validator
    if klass.is_a?(Class) and klass <= Hash
      Oval::HashItem
    elsif klass.is_a?(Class) and klass <= Array
      Oval::ArrayItem
    else
      # well, we also may have klass that is not a class, but I'm too lazy to
      # handle all possible exceptions,
      raise RuntimeError, "Invalid class #{klass.inspect} assigned to klass. " +
        "It seems like we have a bug in #{self.class.name}"
    end
  end

  def self.validate_class_decl(decl)
    klass = self.klass(decl)
    unless klass.is_a?(Class) and ((klass<=Hash) or (klass<=Array))
      raise Oval::DeclError, "Invalid collection class declarator " +
        "#{decl.inspect}. Should be a (subclass of) Hash or Array"
    end
  end
end
