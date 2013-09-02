require 'rspec-system'

module RSpecSystem::Helpers
  class PuppetInstall < RSpecSystem::Helper
    name 'puppet_install'

    def execute
      node = opts[:node]

      # Grab facts from node
      facts = node.facts
      
      # Either use user-defined repository URL base
      # or default based on osfamily fact
      puppet_repo_base = RSpec.configuration.rspec_puppet_repo_base || osfamily_repo_base(facts['osfamily'])

      # Remove annoying mesg n from profile, otherwise on Debian we get:
      # stdin: is not a tty which messes with our tests later on.
      if facts['osfamily'] == 'Debian'
        log.info("Remove 'mesg n' from profile to stop noise")
        shell :c => "sed -i 's/^mesg n/# mesg n/' /root/.profile", :n => node
      end

      # Grab PL repository and install PL copy of puppet
      log.info "Starting installation of puppet from PL repos"
      if facts['osfamily'] == 'RedHat'
        if facts['operatingsystem'] == 'Fedora'
          # Fedora testing is probably the best for now
          shell :c => 'sed -i "0,/RE/s/enabled=0/enabled=1/" /etc/yum.repos.d/fedora-updates-testing.repo', :n => node
        else
          if facts['operatingsystemrelease'] =~ /^6\./
            shell :c => "rpm -ivh #{puppet_repo_base}/el/6/products/x86_64/puppetlabs-release-6-6.noarch.rpm", :n => node
          else
            shell :c => "rpm -ivh #{puppet_repo_base}/el/5/products/x86_64/puppetlabs-release-5-6.noarch.rpm", :n => node
          end
        end
        shell :c => 'yum install -y puppet', :n => node
      elsif facts['osfamily'] == 'Debian'
        shell :c => "wget #{puppet_repo_base}/puppetlabs-release-#{facts['lsbdistcodename']}.deb", :n => node
        shell :c => "dpkg -i puppetlabs-release-#{facts['lsbdistcodename']}.deb", :n => node
        shell :c => 'apt-get update', :n => node
        shell :c => 'apt-get install -y puppet', :n => node
      end

      # Prep modules dir
      log.info("Preparing modules dir")
      shell :c => 'mkdir -p /etc/puppet/modules', :n => node

      # Create alias for puppet
      pp = <<-EOS
host { 'puppet':
  ip => '127.0.0.1',
}
      EOS
      puppet_apply :code => pp, :n => node

      # Create hiera.yaml
      file = Tempfile.new('hierayaml')
      begin
        file.write(<<-EOS)
---
:logger: noop
        EOS
        file.close
        rcp(:sp => file.path, :dp => '/etc/puppet/hiera.yaml', :d => node)
      ensure
        file.unlink
      end

      {}
    end
  end
end
