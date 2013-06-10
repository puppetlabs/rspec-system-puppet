require 'spec_helper_system'

describe "installation tasks" do
  it "check puppet_install works" do
    puppet_install()
  end

  it 'check puppet_master_install works' do
    puppet_master_install()

    puppet_agent do |r|
      r.stderr.should == ''
      r.exit_code.should == 0
    end
  end

  it 'try puppet_agent with debug enabled' do
    puppet_agent(:debug => true) do |r|
      r.stderr.should == ''
      r.stdout.should =~ /Debug:/
      r.exit_code.should == 0
    end
  end
end
