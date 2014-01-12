require 'rspec-system'
require 'rspec-system/helper'
require 'rspec-system/result'
require 'rspec-system-puppet/util'

module RSpecSystem::Helpers
  # Helper object behind RSpecSystemPuppet::Helpers#facter
  class Facter < RSpecSystem::Helper
    name 'facter'
    properties :stdout, :stderr, :exit_code, :facts

    include RSpecSystemPuppet::Util

    def initialize(opts, clr, &block)
      # Defaults etc.
      opts = {
        :puppet => false,
      }.merge(opts)

      super(opts, clr, &block)
    end

    # Gathers new results by executing the resource action
    #
    # @return [RSpecSystem::Result] raw execution results
    def execute
      node = opts[:node]
      
      if is_windows?(opts[:node])
        cmd = "facter.bat --yaml"
      else
        cmd = "facter --yaml"
      end
      
      cmd += " --puppet" if opts[:puppet]
      
      sh = shell :c => cmd, :n => node
      
      rd = sh.to_hash
      rd[:facts] = begin
        YAML::load(sh.stdout)
      rescue
      end

      rd
    end
  end
end
