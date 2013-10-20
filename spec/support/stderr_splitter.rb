require 'stringio'

module RSpec
  class StdErrSplitter < (defined?(::BasicObject) ? ::BasicObject : ::Object)
    def initialize
      @orig_stderr    = $stderr
      @output_tracker = ::StringIO.new
    end

    respond_to_name = (::RUBY_VERSION.to_f < 1.9) ? :respond_to? : :respond_to_missing?
    define_method respond_to_name do |name, include_private=false|
      @orig_stderr.respond_to?(name, include_private) || super
    end

    def method_missing(name, *args, &block)
      @orig_stderr.__send__(name, *args, &block)
      @output_tracker.__send__(name, *args, &block)
    end

    def has_output?
      !output.empty?
    end

    def output
      @output_tracker.string
    end
  end
end

