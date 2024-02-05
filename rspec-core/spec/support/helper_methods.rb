module RSpecHelpers
  SAFE_LEVEL_THAT_TRIGGERS_SECURITY_ERRORS = RUBY_VERSION >= '2.3' ? 1 : 3
  SAFE_IS_GLOBAL_VARIABLE = RUBY_VERSION >= '2.6'

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

    orig_safe = $SAFE
    Thread.new do
      ignoring_warnings { $SAFE = SAFE_LEVEL_THAT_TRIGGERS_SECURITY_ERRORS }
      result = yield
    end.join

    # $SAFE is not supported on Rubinius
    # In Ruby 2.6, $SAFE became a global variable; previously it was local to a thread.
    unless defined?(Rubinius) || SAFE_IS_GLOBAL_VARIABLE
      # $SAFE should not have changed in this thread.
      expect($SAFE).to eql orig_safe
    end

    result
  ensure
    $SAFE = orig_safe if orig_safe && SAFE_IS_GLOBAL_VARIABLE
  end
end
