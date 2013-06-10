require 'rspec-system'

module RSpecSystem::Helpers
  class PuppetAgent < RSpecSystem::Helper
    name 'puppet_agent'
    properties :stdout, :stderr, :exit_code

    def initialize(opts, clr, &block)
      # Defaults etc.
      opts = {
        :debug => false,
        :trace => true,
      }.merge(opts)

      super(opts, clr, &block)
    end

    def execute
      node = opts[:node]

      cmd = "puppet agent -t --detailed-exitcodes"
      cmd += " --debug" if opts[:debug]
      cmd += " --trace" if opts[:trace]

      shell(:c => cmd, :n => node).to_hash
    end
  end
end
