require 'spec_helper_system'

describe "helper puppet_agent" do
  it 'should run without error' do
    puppet_agent do |r|
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end

  context 'test as a subject' do
    context puppet_agent do
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
