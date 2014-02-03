require 'oval/base'

# Describe value that is arbitrary.
class Oval::Anything < Oval::Base
  class << self
    def instance; @instance ||= new; end
    def []; instance; end
    private :new
  end
  def validate(x,subject=nil); end
  def it_should; "be anything"; end
  def initialize(); end
end
