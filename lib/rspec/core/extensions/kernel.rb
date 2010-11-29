module Kernel

  private

  alias_method :method_missing_without_debugger, :method_missing

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
      method_missing_without_debugger(m, *a)
    end
  end
end
