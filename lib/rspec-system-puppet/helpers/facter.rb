require 'rspec-system'
require 'rspec-system/helper'
require 'rspec-system/result'

module RSpecSystem::Helpers
  # Helper object behind RSpecSystemPuppet::Helpers#facter
  class Facter < RSpecSystem::Helper
    name 'facter'
    properties :stdout, :stderr, :exit_code, :facts

    # Gathers new results by executing the resource action
    #
    # @return [RSpecSystem::Result] raw execution results
    def execute
      node = opts[:node]
      sh = shell :c => "facter -y", :n => node

      rd = sh.to_hash
      rd[:facts] = begin
        YAML::load(sh.stdout)
      rescue
      end

      rd
    end
  end
end
