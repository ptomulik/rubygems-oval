require 'oval/base'

# Describe a value that must match one of the shapes.
#
# **Example 1**: Value must be an Array or nil
#
# ```ruby
# OneOf[Container[Array], nil]
# ```
class Oval::OneOf < Oval::Base
  def validate(thing, subject = nil)
    ok = false
    self.decls.each do |decl|
      begin
        self.class.ensure_match(thing, decl)
        ok = true
        break
      rescue Oval::ValueError
      end
    end
    unless ok
      raise Oval::ValueError, "Invalid value #{thing.inspect}#{for_subject(subject)}"
    end
  end

  def it_should
    if decls.empty?
      "be absent"
    else
      output = decls[0..-2].map{|k| self.class.it_should(k)}.join(', ')
      output.empty? ? self.class.it_should(decls[0]) : 
                      [output, self.class.it_should(decls[-1])].join(' or ')
    end
  end

  def initialize(*decls)
    self.decls = decls
  end

  attr_reader :decls

  private
  def decls=(decls)
    @decls = decls
  end
end
