require 'spec_helper_system'

describe "basic tests:" do
  it "check puppet_install works" do
    puppet_install()
  end

  it 'check master install works' do
    puppet_master_install()

    puppet_agent do |r|
      r.stderr.should == ''
      r.exit_code.should == 0
    end
  end

  it 'try puppet agent with debug enabled' do
    puppet_agent(:debug => true) do |r|
      r.stderr.should == ''
      r.stdout.should =~ /Debug:/
      r.exit_code.should == 0
    end
  end

  it 'facter domain should return something valid' do
    facter do |r|
      r.facts['domain'].should =~ /[a-z]+/
      r.exit_code.should == 0
    end
  end

  it 'facter fqdn should return something valid' do
    facter do |r|
      r.stderr.should == ''
      r.facts['fqdn'].should =~ /vm/
      r.exit_code.should == 0
    end
  end

  it 'check puppet_resource returns an exit code of 0' do
    puppet_resource('user') do |r|
      r.stderr.should == ''
      r.exit_code.should == 0
    end
  end

  it 'check puppet apply with just a notice' do
    puppet_apply('notice("foo")') do |r|
      r.stdout.should =~ /foo/
      r.stderr.should == ''
      r.exit_code.should == 0
    end
  end

  it 'try puppet apply with debug mode' do
    puppet_apply(:code => 'notice("foo")', :debug => true) do |r|
      r.stdout.should =~ /foo/
      r.stdout.should =~ /Debug:/
      r.stderr.should == ''
      r.exit_code.should == 0
    end
  end

  it 'try puppet apply with trace off' do
    puppet_apply(:code => 'notice("foo")', :trace => false) do |r|
      r.stdout.should =~ /foo/
      r.stderr.should == ''
      r.exit_code.should == 0
    end
  end

  it 'check for no errors when including a class' do
    puppet_module_install(
      :source => proj_root + 'spec' + 'fixtures' + 'mymodule',
      :module_name => 'mymodule'
    )
    pp = <<-EOS.gsub(/^\s{6}/, '')
      class { 'mymodule':
        param1 => 'bar',
      }
    EOS
    puppet_apply(pp) do |r|
      r.stdout.should =~ /Param1: bar/
      r.stderr.should == ''
      r.exit_code.should == 0
    end
  end
end
