module Oval
  require 'oval/anything'
  require 'oval/collection'
  require 'oval/instance_of'
  require 'oval/kind_of'
  require 'oval/one_of'
  require 'oval/options'
  require 'oval/subclass_of'


  def ov_anything; Oval::Anything; end
  def ov_collection; Oval::Collection; end
  def ov_instance_of; Oval::InstanceOf; end
  def ov_kind_of; Oval::KindOf; end
  def ov_one_of; Oval::OneOf; end
  def ov_options; Oval::Options; end
  def ov_subclass_of; Oval::SubclassOf; end
end
