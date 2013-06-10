# rspec-system-puppet

`rspec-system-puppet` is a Puppet plugin for [rspec-system](https://rubygems.org/gems/rspec-system). The goal here is to provide a series of helpers for performing proper system tests on Puppet related modules such as:

* Pure Puppet DSL content, classes and defined resources
* Ruby based plugins: facts, functions, faces, types and providers

## Relation to rspec-puppet

While unit testing using [rspec-puppet](https://rubygems.org/gems/rspec-puppet) is extremely useful for testing your content based on comparing input of parameters, facts etc. with the desired catalog output, it doesn't however do a real test. This library is meant to augment the rspec-puppet test suite, and is designed specifically to work with it. In fact I suggest running both these tests in parallel with rspec-puppet, as rspec-puppet is always going to execute basic tests faster - especially tests that don't need a real run like comparing template output with desired output, or fine-detailed items like expected property values and logical blocks.

## Quick Start

Recommended to be installed first:

* Vagrant 1.2.2 or greater
* VirtualBox 4.2.10 or greater
* RVM or RBenv (current instructions are based on RVM however)

In your existing Puppet module project, create a `.nodeset.yml` with the following contents:

    ---
    default_set: 'centos-64-x64'
    sets:
      'centos-59-x64':
        nodes:
          "main.foo.vm":
            prefab: 'centos-59-x64'
      'centos-64-x64':
        nodes:
          "main.foo.vm":
            prefab: 'centos-64-x64'
      'fedora-18-x64':
        nodes:
          "main.foo.vm":
            prefab: 'fedora-18-x64'
      'debian-607-x64':
        nodes:
          "main.foo.vm":
            prefab: 'debian-607-x64'
      'debian-70rc1-x64':
        nodes:
          "main.foo.vm":
            prefab: 'debian-70rc1-x64'
      'ubuntu-server-10044-x64':
        nodes:
          "main.foo.vm":
            prefab: 'ubuntu-server-10044-x64'
      'ubuntu-server-12042-x64':
        nodes:
          "main.foo.vm":
            prefab: 'ubuntu-server-12042-x64'

Make sure you have a `Gemfile` like the one below, this includes `rspec-puppet` test content as well:

    source 'https://rubygems.org'

    group :development, :test do
      gem 'rake'
      gem 'puppetlabs_spec_helper', :require => false
      gem 'rspec-system-puppet'
      gem 'puppet-lint'
    end

    if puppetversion = ENV['PUPPET_GEM_VERSION']
      gem 'puppet', puppetversion, :require => false
    else
      gem 'puppet', :require => false
    end

Create a `Rakefile` like so:

    require 'rubygems'
    require 'bundler/setup'

    Bundler.require :default

    require 'rspec/core/rake_task'
    require 'puppetlabs_spec_helper/rake_tasks'
    require 'rspec-system/rake_task'

    task :default do
      sh %{rake -T}
    end

You will need a spec helper for your tests to `require`. So create the file `spec/spec_helper_system.rb`:

    require 'rspec-system/spec_helper'
    require 'rspec-system-puppet/helpers'

    include RSpecSystemPuppet::Helpers

    RSpec.configure do |c|
      # Project root for the firewall code
      proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

      # Enable colour in Jenkins
      c.tty = true

      c.include RSpecSystemPuppet::Helpers

      # This is where we 'setup' the nodes before running our tests
      c.before :suite do
        # Install puppet
        puppet_install
        puppet_master_install

        # Replace mymodule with your module name
        puppet_module_install(:source => proj_root, :module_name => 'mymodule')
      end
    end

Now if you are using rspec-puppet, I advise you to seperate the location of your system and unit tests:

* spec/system - system tests
* spec/unit - rspec-puppet and other unit tests

And create your first system tests in say `spec/system/basic_spec.rb` (make sure it has the _spec.rb suffix!):

    require 'spec_helper_system'

    describe 'basic tests:' do
      # Using puppet_apply as a subject
      context puppet_apply 'notice("foo")' do
        its(:stdout) { should =~ /foo/ }
        its(:stderr) { should be_empty }
        its(:exit_code) { should be_zero }
      end

      # Using puppet_apply as a helper
      it 'my class should work with no errors' do
        pp = <<-EOS
          class { 'mymodule': }
        EOS
      
        # Run it once and make sure it doesn't bail with errors
        puppet_apply(pp) do |r|
          r.exit_code.should_not eq(1)
        end

        # Run it again and make sure no changes occurred this time, proving idempotency
        puppet_apply(pp) do |r|
          r.exit_code.should be_zero
        end
      end
    end

Now start by creating a gemset environment for your run:

    # rvm --create --ruby-version use ruby-1.9.3@mymodule

Then grab the gemset bundle:

    # bundle update

Now you should be able to do:

    # rake spec:system
    
If you want to test an alternate set, just use the RSPEC_SET environment variable like so:

    # RSPEC_SET=debian-70rc1-x64 rake spec:system
    
Consult the .nodeset.yml file for the list of sets.

## Further Information

* [API Documentation](http://rubydoc.info/gems/rspec-system-puppet/) - this provides the Ruby API docs for the Puppet Helpers. In particular look at the [Helpers](http://rubydoc.info/gems/rspec-system-puppet/RSpecSystemPuppet/Helpers) sub-class.
* [rspec-system docs](http://rubydoc.info/gems/rspec-system) - This is the main library rspec-system-puppet utilises, and should provide more in-depth instructions on doing more complex stuff than what this gem alone provides.
* [puppetlabs-firewall](http://github.com/puppetlabs/puppetlabs-firewall) - If you want to see the library in action this module is the primary guinea pig for rspec-system-puppet and should give you some ideas on writing tests of your own. Look under `spec/system` for the tests.
* [puppetlabs-puppetdb](http://github.com/puppetlabs/puppetlabs-puppetdb) - Another example of the module in action.

## CI Integration

For now consult the documentation for [rspec-system](http://rubygems.org/gems/rspec-system) for more details.
