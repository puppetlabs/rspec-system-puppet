require 'rspec-system'

module RSpecSystem::Helpers
  class PuppetModuleInstall < RSpecSystem::Helper
    name 'puppet_module_install'

    def initialize(opts, clr, &block)
      opts = {
        :module_path => "/etc/puppet/modules",
        :skip => [".rspec_system"]
      }.merge(opts)

      raise "Must provide :source and :module_name parameters" unless opts[:source] && opts[:module_name]

      super(opts, clr, &block)
    end

    def execute
      source = opts[:source]
      module_name = opts[:module_name]
      module_path = opts[:module_path]
      node = opts[:node]
      skip = opts.has_key?(:skip) ? opts[:skip] : Array.new

      log.info("Now transferring module onto node")

      source_contents = Dir.entries(source) - ['.','..']
      puts source_contents
      source_contents.each do |file|
        unless skip.include? file
          shell :c => "mkdir -p \"#{File.join(module_path, module_name)}\"", :n => node
          result = rcp :sp => "#{source}/#{file}", :d => node, :dp => File.join(module_path, module_name, file)
          unless result[:success]
            return result
          end
        end
      end
      {:success => true}
    end
  end
end
