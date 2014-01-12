require 'rspec-system'
require 'rspec-system-puppet/util'

module RSpecSystem::Helpers
  # puppet_apply helper
  class PuppetApply < RSpecSystem::Helper
    name 'puppet_apply'
    properties :stdout, :stderr, :exit_code

    include RSpecSystemPuppet::Util

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
      user = opts[:user]

      log.info("Copying DSL to remote host")
      file = Tempfile.new('rcp_puppet_apply')
      file.write(code)
      file.close
      
      if is_windows?(node)
        tmp_path = 'C:/Windows/Temp/'
      else
        tmp_path = '/tmp/'
      end

      remote_path = tmp_path + 'puppetapply.' + rand(1000000000).to_s
      r = rcp(:sp => file.path, :dp => remote_path, :d => node)
      file.unlink

      log.info("Cat file to see contents")
      if is_windows?(node)
        shell :c => "type #{remote_path}", :n => node
      else
        shell :c => "cat #{remote_path}", :n => node
      end

      log.info("Now running puppet apply")
      if is_windows?(node)
        cmd = "puppet.bat apply"
      else
        cmd = "puppet apply"
      end
  
      cmd += " --detailed-exitcodes"
      cmd += " --debug" if opts[:debug]
      cmd += " --trace" if opts[:trace]
      cmd += " --modulepath #{opts[:module_path]}" if opts[:module_path]
      cmd += " #{remote_path}"
      
      #cmd = "chown #{user} #{remote_path} && su - #{user} -c '#{cmd}'" if user

      shell(:c => cmd, :n => node).to_hash
    end
  end
end
