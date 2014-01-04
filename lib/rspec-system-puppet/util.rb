module RSpecSystemPuppet::Util
  def is_windows?(node)
    cmd = 'pwd'
    sh = shell :c => cmd, :n => node
    if sh.stdout.include?('cygdrive')
      return true
    else
      return false
    end
  end
end