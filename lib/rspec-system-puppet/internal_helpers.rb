require 'rspec-system-puppet'

module RSpecSystemPuppet::InternalHelpers
  # Return the BASE URL for Puppetlabs repo
  #
  # @return [String]
  def rspec_puppet_repo_base
    base = ENV["RSPEC_PUPPET_REPO_BASE"] || nil
  end

  # Return the default base URL for Puppetlabs repos
  # based on the osfamily value
  #
  # @param osfamily [String] the node's osfamily fact value
  # @return [String]
  def osfamily_repo_base(osfamily)
    case osfamily
    when 'RedHat'
      'http://yum.puppetlabs.com'
    when 'Debian'
      'http://apt.puppetlabs.com'
    else
      nil
    end
  end
end