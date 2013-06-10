require 'rspec-system'

module RSpecSystem::Helpers
  class PuppetMasterInstall < RSpecSystem::Helper
    name 'puppet_master_install'

    def execute
      node = opts[:node]
      facts = node.facts

      if facts['osfamily'] == 'RedHat'
        shell :c => 'yum install -y puppet-server', :n => node
        if facts['operatingsystemrelease'] =~ /^5\./
          shell :c => '/etc/init.d/puppetmaster start', :n => node
        else
          shell :c => 'service puppetmaster start', :n => node
        end
      elsif facts['osfamily'] == 'Debian'
        shell :c => 'apt-get install -y puppetmaster', :n => node
        shell :c => 'service puppetmaster start', :n => node
      end

      {}
    end
  end
end
