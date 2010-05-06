module Kernel
  def debugger(*args)
    $stderr.puts "debugger statement ignored, use -d or --debug option on rspec to enable debugging"
  end
end
