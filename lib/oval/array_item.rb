require 'oval/base'

class Oval::ArrayItem < Oval::Base

  def validate(item, i, subject = nil)
    item_subject = subject.nil? ? nil : "#{subject}[#{i}]"
    self.class.ensure_match(item,item_decl,item_subject)
  end

  def self.[](item_decl)
    new(item_decl)
  end

  def initialize(item_decl)
    self.item_decl = item_decl
  end

  attr_reader :item_decl

  protected

  def item_decl=(decl)
    @item_decl = decl
  end
end
