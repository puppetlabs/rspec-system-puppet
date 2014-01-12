require 'rspec-system'

module RSpecSystem::Helpers
  class PuppetInstall < RSpecSystem::Helper
    name 'puppet_install'

    def execute
      node = opts[:node]

      # Grab facts from node
      facts = node.facts

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
            shell :c => 'rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm', :n => node
          else
            shell :c => 'rpm -ivh http://yum.puppetlabs.com/el/5/products/x86_64/puppetlabs-release-5-7.noarch.rpm', :n => node
          end
        end
        shell :c => 'yum install -y puppet', :n => node
      elsif facts['osfamily'] == 'Debian'
        shell :c => "wget http://apt.puppetlabs.com/puppetlabs-release-#{facts['lsbdistcodename']}.deb", :n => node
        shell :c => "dpkg -i puppetlabs-release-#{facts['lsbdistcodename']}.deb", :n => node
        shell :c => 'apt-get update', :n => node
        shell :c => 'apt-get install -y puppet', :n => node
      elsif facts['osfamily'] == 'windows'
        # Download the file locally - assumes powershell v2 is already installed
        shell :c => 'echo . | powershell.exe -NoLogo -Command \"&{ (New-Object Net.WebClient).DownloadFile(\'http://downloads.puppetlabs.com/windows/puppet-3.4.1.msi\', \'C:\Windows\Temp\puppet-3.4.1.msi\') }\"', :n => node
        
        shell :c => 'echo . | powershell.exe -NoLogo -Command \"&{ Start-Process msiexec.exe -ArgumentList \'/qn /i C:\Windows\Temp\puppet-3.4.1.msi /l*v C:\Windows\Temp\puppet_install.log\' -Wait }\"', :n => node
      end
      
      if facts['osfamily'] == 'windows'
        puppet_dir = '/cygdrive/c/etc/puppet'
      else
        puppet_dir = '/etc/puppet'
      end

      # Prep modules dir
      log.info("Preparing modules dir")
      shell :c => "mkdir -p #{puppet_dir}/modules", :n => node
      
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
        rcp(:sp => file.path, :dp => "#{puppet_dir}/hiera.yaml", :d => node)
      ensure
        file.unlink
      end

      {}
    end
  end
end
