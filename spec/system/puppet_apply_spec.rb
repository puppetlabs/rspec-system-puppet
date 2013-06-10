require 'spec_helper_system'

describe "helper puppet_apply" do
  it 'should print notice message to stdout' do
    puppet_apply('notice("foo")') do |r|
      r.stdout.should =~ /foo/
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end

  it 'in debug mode should return notice message to stdout and Debug: labels' do
    puppet_apply(:code => 'notice("foo")', :debug => true) do |r|
      r.stdout.should =~ /foo/
      r.stdout.should =~ /Debug:/
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end

  it 'with trace off it should work normally' do
    puppet_apply(:code => 'notice("foo")', :trace => false) do |r|
      r.stdout.should =~ /foo/
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end

  context 'test as a subject' do
    context puppet_apply 'notice("foo")' do
      its(:stdout) { should =~ /foo/ }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
