require 'rspec-system'

module RSpecSystem::Helpers
  class PuppetResource < RSpecSystem::Helper
    name 'puppet_resource'
    properties :stdout, :stderr, :exit_code

    def initialize(opts, clr, &block)
      raise "Must provide resource" unless opts[:resource]
      super(opts, clr, &block)
    end

    # Run puppet resource in a shell and return results
    #
    # @return [Hash] results
    def execute
      resource = opts[:resource]
      node = opts[:node]

      log.info("Now running puppet resource")
      result = shell :c => "puppet resource #{resource}", :n => node
      result.to_hash
    end
  end
end
