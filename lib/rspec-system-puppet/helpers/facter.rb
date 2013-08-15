require 'rspec-system'
require 'rspec-system/helper'
require 'rspec-system/result'

module RSpecSystem::Helpers
  # Helper object behind RSpecSystemPuppet::Helpers#facter
  class Facter < RSpecSystem::Helper
    name 'facter'
    properties :stdout, :stderr, :exit_code, :facts

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
      
      cmd = "facter --yaml"
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
