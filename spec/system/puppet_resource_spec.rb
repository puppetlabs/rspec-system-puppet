require 'spec_helper_system'

describe "helper puppet_resource" do
  it 'for "user" should returns an exit code of 0' do
    puppet_resource('user') do |r|
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end

  context 'test as a subject' do
    context puppet_resource 'user' do
      its(:stdout) { should_not be_empty }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
