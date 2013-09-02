require 'rspec-system-puppet/internal_helpers'

include RSpecSystemPuppet::InternalHelpers

RSpec.configure do |c|
  c.include RSpecSystemPuppet::InternalHelpers

  c.add_setting :rspec_puppet_repo_base
  
  c.rspec_puppet_repo_base = rspec_puppet_repo_base
end
