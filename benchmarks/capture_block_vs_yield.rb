require 'benchmark/ips'

def yield_control
  yield
end

def capture_block_and_yield(&block)
  yield
end

def capture_block_and_call(&block)
  block.call
end

Benchmark.ips do |x|
  x.report("yield                  ") do
    yield_control { }
  end

  x.report("capture block and yield") do
    capture_block_and_yield { }
  end

  x.report("capture block and call ") do
    capture_block_and_call { }
  end
end

__END__

This benchmark demonstrates that `yield` is much, much faster
than capturing `&block` and calling it. In fact, the simple act
of capturing `&block`, even if we don't later reference `&block`,
incurs most of the cost, so we should avoid capturing blocks unless
we absolutely need to.

Calculating -------------------------------------
yield
                        93.104k i/100ms
capture block and yield
                        52.682k i/100ms
capture block and call
                        51.115k i/100ms
-------------------------------------------------
yield
                          5.161M (±10.6%) i/s -     25.231M
capture block and yield
                          1.141M (±22.0%) i/s -      5.426M
capture block and call
                          1.027M (±21.8%) i/s -      4.856M
