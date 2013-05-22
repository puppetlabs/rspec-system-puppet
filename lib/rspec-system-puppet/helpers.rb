require 'rspec-system-puppet'

module RSpecSystemPuppet::Helpers
  include RSpecSystem::Helpers
  include RSpecSystem::Log

  # Basic helper to install puppet
  #
  # @param opts [Hash] a hash of opts
  def puppet_install(opts = {})
    # Grab facts from node
    facts = system_node.facts

    # Remove annoying mesg n from profile, otherwise on Debian we get:
    # stdin: is not a tty which messes with our tests later on.
    if facts['osfamily'] == 'Debian'
      log.info("Remove 'mesg n' from profile to stop noise")
      system_run("sed -i 's/^mesg n/# mesg n/' /root/.profile")
    end

    # Grab PL repository and install PL copy of puppet
    log.info "Starting installation of puppet from PL repos"
    if facts['osfamily'] == 'RedHat'
      if facts['operatingsystem'] == 'Fedora'
        # Fedora testing is probably the best for now
        system_run('sed -i "0,/RE/s/enabled=0/enabled=1/" /etc/yum.repos.d/fedora-updates-testing.repo')
      else
        if facts['operatingsystemrelease'] =~ /^6\./
          system_run('rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-6.noarch.rpm')
        else
          system_run('rpm -ivh http://yum.puppetlabs.com/el/5/products/x86_64/puppetlabs-release-5-6.noarch.rpm')
        end
      end
      system_run('yum install -y puppet')
    elsif facts['osfamily'] == 'Debian'
      system_run("wget http://apt.puppetlabs.com/puppetlabs-release-#{facts['lsbdistcodename']}.deb")
      system_run("dpkg -i puppetlabs-release-#{facts['lsbdistcodename']}.deb")
      system_run('apt-get update')
      system_run('apt-get install -y puppet')
    end

    # Prep modules dir
    log.info("Preparing modules dir")
    system_run('mkdir -p /etc/puppet/modules')

    # Create alias for puppet
    pp = <<-EOS
host { 'puppet':
  ip => '127.0.0.1',
}
    EOS
    puppet_apply(pp)

    # Create hiera.yaml
    file = Tempfile.new('hierayaml')
    begin
      file.write(<<-EOS)
---
:logger: noop
      EOS
      file.close
      system_rcp(:sp => file.path, :dp => '/etc/puppet/hiera.yaml')
    ensure
      file.unlink
    end
  end

  # Basic helper to install a puppet master
  #
  # @param opts [Hash] a hash of opts
  def puppet_master_install
    # Defaults etc.
    opts = {
      :node => rspec_system_node_set.default_node,
    }

    node = opts[:node]

    # Grab facts from node
    facts = system_node(:node => node).facts

    if facts['osfamily'] == 'RedHat'
      system_run(:n => node, :c => 'yum install -y puppet-server')
      if facts['operatingsystemrelease'] =~ /^5\./
        system_run(:n => node, :c => '/etc/init.d/puppetmaster start')
      else
        system_run(:n => node, :c => 'service puppetmaster start')
      end
    elsif facts['osfamily'] == 'Debian'
      system_run(:n => node, :c => 'apt-get install -y puppetmaster')
      system_run(:n => node, :c => 'service puppetmaster start')
    end
  end

  # Run puppet agent
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @option opts [Boolean] :debug true if debugging required
  # @option opts [Boolean] :trace true if trace required
  # @return [RSpecSystem::Result] results containing keys :exit_code, :stdout and :stderr
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Result] a hash containing :exit_code, :stdout and :stderr
  # @example
  #   puppet_agent.do |r|
  #     r.exit_code.should == 0
  #   end
  # @example with debugging enabled
  #   puppet_agent(:debug => true).do |r|
  #     r.exit_code.should == 0
  #   end
  def puppet_agent(opts = {})
    # Defaults etc.
    opts = {
      :node => rspec_system_node_set.default_node,
      :debug => false,
      :trace => true,
    }.merge(opts)

    node = opts[:node]

    cmd = "puppet agent -t --detailed-exitcodes"
    cmd += " --debug" if opts[:debug]
    cmd += " --trace" if opts[:trace]
    result = system_run(:n => node, :c => cmd)

    if block_given?
      yield(result)
    else
      result
    end
  end

  # Helper to copy a module onto a node from source
  #
  # @param opts [Hash] a hash of opts
  def puppet_module_install(opts)
    # Defaults etc.
    opts = {
      :node => rspec_system_node_set.default_node,
      :module_path => "/etc/puppet/modules",
    }.merge(opts)

    source = opts[:source]
    module_name = opts[:module_name]
    module_path = opts[:module_path]
    node = opts[:node]

    raise "Must provide :source and :module_name parameters" unless source && module_name

    log.info("Now transferring module onto node")
    system_rcp(:sp => source, :d => node, :dp => File.join(module_path, module_name))
  end

  # Runs puppet resource commands
  #
  # @param opts [Hash] a hash of opts
  # @return [RSpecSystem::Result] results containing keys :exit_code, :stdout and :stderr
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Result] a hash containing :exit_code, :stdout and :stderr
  def puppet_resource(opts)
    if opts.is_a?(String)
      opts = {:resource => opts}
    end

    # Defaults
    opts = {
      :node => rspec_system_node_set.default_node
    }.merge(opts)

    resource = opts[:resource]
    node = opts[:node]

    raise 'Must provide resource' unless resource

    log.info("Now running puppet resource")
    result = system_run(:n => node, :c => "puppet resource #{resource}")

    if block_given?
      yield(result)
    else
      result
    end
  end

  # Run puppet DSL code directly with `puppet apply`.
  #
  # This takes a string of PuppetDSL code, uploads it to the test server and
  # executes it directly with `puppet apply`.
  #
  # @param opts [Hash, String] a hash of opts, or a string containing the
  #   code to execute with option defaults
  # @option opts [String] :code the Puppet DSL code to execute
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @option opts [Boolean] :debug true if debugging required
  # @option opts [Boolean] :trace true if trace required
  # @return [RSpecSystem::Result] results containing keys :exit_code, :stdout and :stderr
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Result] a hash containing :exit_code, :stdout and :stderr
  # @example
  #   it "run notice" do
  #     puppet_apply("notice('foo')") do |r|
  #       r.stdout.should =~ /foo/
  #     end
  #   end
  def puppet_apply(opts)
    if opts.is_a?(String)
      opts = {:code => opts}
    end

    # Defaults
    opts = {
      :node => rspec_system_node_set.default_node,
      :debug => false,
      :trace => true,
    }.merge(opts)

    code = opts[:code]
    node = opts[:node]

    raise 'Must provide code' unless code

    log.info("Copying DSL to remote host")
    file = Tempfile.new('rsp_puppet_apply')
    file.write(code)
    file.close

    remote_path = '/tmp/puppetapply.' + rand(1000000000).to_s
    r = system_rcp(:sp => file.path, :dp => remote_path, :d => node)
    file.unlink

    log.info("Cat file to see contents")
    system_run(:n => node, :c => "cat #{remote_path}")

    log.info("Now running puppet apply")
    cmd = "puppet apply --detailed-exitcodes"
    cmd += " --debug" if opts[:debug]
    cmd += " --trace" if opts[:trace]
    cmd += " #{remote_path}"
    result = system_run(:n => node, :c => cmd)

    if block_given?
      yield(result)
    else
      result
    end
  end

  # Run facter on a remote machine
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @return [RSpecSystem::Result] a hash of results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Result] result containing :facts, :exit_code, :stdout and
  #   :stderr
  def facter(opts = {})
    # Defaults
    opts = {
      :node => rspec_system_node_set.default_node,
    }.merge(opts)

    node = opts[:node]

    raise "Must specify a node" unless node

    cmd = "facter -y"
    result = system_run(:n => node, :c => cmd)

    begin
      facts = YAML::load(result[:stdout])
      result.facts = facts
    rescue
    end

    if block_given?
      yield(result)
    else
      result
    end
  end
end
