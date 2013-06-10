require 'rspec-system'

module RSpecSystem::Helpers
  class PuppetModuleInstall < RSpecSystem::Helper
    name 'puppet_module_install'

    def initialize(opts, clr, &block)
      opts = {
        :module_path => "/etc/puppet/modules",
      }.merge(opts)

      raise "Must provide :source and :module_name parameters" unless opts[:source] && opts[:module_name]

      super(opts, clr, &block)
    end

    def execute
      source = opts[:source]
      module_name = opts[:module_name]
      module_path = opts[:module_path]
      node = opts[:node]

      log.info("Now transferring module onto node")
      result = rcp :sp => source, :d => node, :dp => File.join(module_path, module_name)
      result.to_hash
    end
  end
end
