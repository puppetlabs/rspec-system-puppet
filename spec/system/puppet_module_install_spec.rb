require 'spec_helper_system'

describe "helper puppet_module_install" do
  let(:test_path) do
    proj_root + 'spec' + 'fixtures' + 'mymodule'
  end

  it 'should return no errors when including a class' do
    puppet_module_install(
      :source => test_path,
      :module_name => 'mymodule'
    )
    pp = <<-EOS.gsub(/^\s{6}/, '')
      class { 'mymodule':
        param1 => 'bar',
      }
    EOS
    puppet_apply(pp) do |r|
      r.stdout.should =~ /Param1: bar/
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end
end
