require 'spec_helper_system'

describe "helper facter" do
  it 'domain fact should return something valid' do
    facter do |r|
      r.stderr.should be_empty
      r.facts['domain'].should =~ /[a-z]+/
      r.exit_code.should be_zero
    end
  end

  it 'fqdn fact should return something valid' do
    facter do |r|
      r.stderr.should be_empty
      r.facts['fqdn'].should =~ /vm/
      r.exit_code.should be_zero
    end
  end

  context 'test as a subject' do
    context facter do
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }

      it { subject.facts['fqdn'].should =~ /vm/ }
    end
  end
end
