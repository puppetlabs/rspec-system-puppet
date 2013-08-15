require 'rspec-system-puppet'
require 'rspec-system-puppet/helpers/facter'
require 'rspec-system-puppet/helpers/puppet_apply'
require 'rspec-system-puppet/helpers/puppet_resource'
require 'rspec-system-puppet/helpers/puppet_module_install'
require 'rspec-system-puppet/helpers/puppet_install'
require 'rspec-system-puppet/helpers/puppet_master_install'
require 'rspec-system-puppet/helpers/puppet_agent'

# This module contains the methods provide by rspec-system-puppet
module RSpecSystemPuppet::Helpers
  include RSpecSystem::Helpers

  # Basic helper to install puppet
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @return [RspecSystemPuppet::Helpers::PuppetInstall] results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Helpers::PuppetInstall] results
  def puppet_install(opts = {}, &block)
    RSpecSystemPuppet::Helpers::PuppetInstall.new(opts, self, &block)
  end

  # Basic helper to install a puppet master
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @return [RspecSystemPuppet::Helpers::PuppetMasterInstall] results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Helpers::PuppetMasterInstall] results
  def puppet_master_install(opts = {}, &block)
    RSpecSystemPuppet::Helpers::PuppetMasterInstall.new(opts, self, &block)
  end

  # Run puppet agent
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @option opts [Boolean] :debug true if debugging required
  # @option opts [Boolean] :trace true if trace required
  # @return [RSpecSystem::Helpers::PuppetAgent] results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Helpers::PuppetAgent] results
  # @example
  #   puppet_agent.do |r|
  #     r.exit_code.should == 0
  #   end
  # @example with debugging enabled
  #   puppet_agent(:debug => true).do |r|
  #     r.exit_code.should == 0
  #   end
  def puppet_agent(opts = {}, &block)
    RSpecSystemPuppet::Helpers::PuppetAgent.new(opts, self, &block)
  end

  # Helper to copy a module onto a node from source
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @return [RSpecSystem::Helpers::PuppetModuleInstall] results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Helpers::PuppetModuleInstall] results
  def puppet_module_install(opts, &block)
    RSpecSystemPuppet::Helpers::PuppetModuleInstall.new(opts, self, &block)
  end

  # Runs puppet resource commands
  #
  # @param opts [Hash] a hash of opts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @return [RSpecSystem::Helpers::PuppetResource] results
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystem::Helpers::PuppetResource] results
  def puppet_resource(opts, &block)
    if opts.is_a?(String)
      opts = {:resource => opts}
    end

    RSpecSystemPuppet::Helpers::PuppetResource.new(opts, self, &block)
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
  # @option opts [String] :module_path puppet modulepath to use
  # @return [RSpecSystem::Helpers::PuppetApply] helper object
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystemPuppet::Helpers::PuppetApply] helper object
  #   it "run notice" do
  #     puppet_apply("notice('foo')") do |r|
  #       r.stdout.should =~ /foo/
  #     end
  #   end
  def puppet_apply(opts, &block)
    if opts.is_a?(String)
      opts = {:code => opts}
    end

    RSpecSystemPuppet::Helpers::PuppetApply.new(opts, self, &block)
  end

  # Run facter on a remote machine
  #
  # @param opts [Hash] a hash of opts
  # @option opts [Boolean] :puppet true to load Puppet custom facts
  # @option opts [RSpecSystem::Node] :node node to execute DSL on
  # @return [RSpecSystemPuppet::Helpers::Facter] helper object
  # @yield [result] yields result when called as a block
  # @yieldparam result [RSpecSystemPuppet::Helpers::Facter] helper object
  def facter(opts = {}, &block)
    RSpecSystemPuppet::Helpers::Facter.new(opts, self, &block)
  end
end
