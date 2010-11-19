module Kernel
  def method_missing(m, *a)
    if m.to_s == 'debugger'
      begin
        require 'ruby-debug'
        debugger
      rescue LoadError => e
        warn <<-EOM
#{'*'*50}
The debugger statement on the following line was ignored:

  #{caller(0).detect {|l| l !~ /method_missing/}}
 
To use the debugger statement, you must install ruby-debug.
#{'*'*50}
EOM
      end
    else
      super
    end
  end
end
