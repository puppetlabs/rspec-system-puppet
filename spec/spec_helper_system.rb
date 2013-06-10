require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

include RSpecSystemPuppet::Helpers

def proj_root
  Pathname.new(File.join(File.dirname(__FILE__), '..'))
end

RSpec.configure do |c|
  c.include RSpecSystemPuppet::Helpers
end
