module RSpecHelpers
  SAFE_LEVEL_THAT_TRIGGERS_SECURITY_ERRORS = RUBY_VERSION >= '2.3' ? 1 : 3

  def relative_path(path)
    RSpec::Core::Metadata.relative_path(path)
  end

  def ignoring_warnings
    original = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original
    result
  end

  def with_safe_set_to_level_that_triggers_security_errors
    result = nil

    Thread.new do
      ignoring_warnings { $SAFE = SAFE_LEVEL_THAT_TRIGGERS_SECURITY_ERRORS }
      result = yield
    end.join

    # $SAFE is not supported on Rubinius
    unless defined?(Rubinius)
      expect($SAFE).to eql 0 # $SAFE should not have changed in this thread.
    end

    result
  end

end
