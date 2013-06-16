require 'rspec-system'

module RSpecSystem::Helpers
  # puppet_apply helper
  class PuppetApply < RSpecSystem::Helper
    name 'puppet_apply'
    properties :stdout, :stderr, :exit_code

    def initialize(opts, clr, &block)
      # Defaults
      opts = {
        :debug => false,
        :trace => true,
      }.merge(opts)

      raise 'Must provide code' unless opts[:code]

      super(opts, clr, &block)
    end

    # Run puppet apply in a shell and return results
    #
    # @return [Hash] results
    def execute
      code = opts[:code]
      node = opts[:node]

      log.info("Copying DSL to remote host")
      file = Tempfile.new('rcp_puppet_apply')
      file.write(code)
      file.close

      remote_path = '/tmp/puppetapply.' + rand(1000000000).to_s
      r = rcp(:sp => file.path, :dp => remote_path, :d => node)
      file.unlink

      log.info("Cat file to see contents")
      shell :c => "cat #{remote_path}", :n => node

      log.info("Now running puppet apply")
      cmd = "puppet apply --detailed-exitcodes"
      cmd += " --debug" if opts[:debug]
      cmd += " --trace" if opts[:trace]
      cmd += " --modulepath #{opts[:module_path]}" if opts[:module_path]
      cmd += " #{remote_path}"

      shell(:c => cmd, :n => node).to_hash
    end
  end
end
