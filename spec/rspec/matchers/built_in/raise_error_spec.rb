require 'spec_helper'

describe "expect { ... }.to raise_error" do
  it_behaves_like("an RSpec matcher", :valid_value => lambda { raise "boom" },
                                      :invalid_value => lambda { }) do
    let(:matcher) { raise_error(/boom/) }
  end

  it "passes if anything is raised" do
    expect {raise}.to raise_error
  end

  it "passes if an error instance is expected" do
    s = StandardError.new
    expect {raise s}.to raise_error(s)
  end

  it "fails if a different error instance is thrown from the one that is expected" do
    s = StandardError.new("Error 1")
    to_raise = StandardError.new("Error 2")
    expect do
      expect {raise to_raise}.to raise_error(s)
    end.to fail_with(Regexp.new("expected #{s.inspect}, got #{to_raise.inspect} with backtrace"))
  end

  it "passes if an error class is expected and an instance of that class is thrown" do
    s = StandardError.new :bees

    expect { raise s }.to raise_error(StandardError)
  end

  it "fails if nothing is raised" do
    expect {
      expect {}.to raise_error
    }.to fail_with("expected Exception but nothing was raised")
  end
end

describe "raise_exception aliased to raise_error" do
  it "passes if anything is raised" do
    expect {raise}.to raise_exception
  end
end

describe "expect { ... }.to raise_error {|err| ... }" do
  it "passes if there is an error" do
    ran = false
    expect { non_existent_method }.to raise_error {|e|
      ran = true
    }
    expect(ran).to be_truthy
  end

  it "passes the error to the block" do
    error = nil
    expect { non_existent_method }.to raise_error {|e|
      error = e
    }
    expect(error).to be_kind_of(NameError)
  end
end

describe "expect { ... }.to raise_error do |err| ... end" do
  it "passes the error to the block" do
    error = nil
    expect { non_existent_method }.to raise_error do |e|
      error = e
    end
    expect(error).to be_kind_of(NameError)
  end
end

describe "expect { ... }.to(raise_error { |err| ... }) do |err| ... end" do
  it "passes the error only to the block taken directly by #raise_error" do
    error_passed_to_curly = nil
    error_passed_to_do_end = nil

    expect { non_existent_method }.to(raise_error { |e| error_passed_to_curly = e }) do |e|
      error_passed_to_do_end = e
    end

    expect(error_passed_to_curly).to be_kind_of(NameError)
    expect(error_passed_to_do_end).to be_nil
  end
end

describe "expect { ... }.not_to raise_error" do

  context "with a specific error class" do
    it "is invalid" do
      expect {
        expect {"bees"}.not_to raise_error(RuntimeError)
      }.to raise_error(/`expect \{ \}\.not_to raise_error\(SpecificErrorClass\)` is not valid/)
    end
  end

  context "with no specific error class" do
    it "passes if nothing is raised" do
      expect {}.not_to raise_error
    end

    it "fails if anything is raised" do
      expect {
        expect { raise RuntimeError, "example message" }.not_to raise_error
      }.to fail_with(/expected no Exception, got #<RuntimeError: example message>/)
    end

    it 'includes the backtrace of the error that was raised in the error message' do
      expect {
        expect { raise "boom" }.not_to raise_error
      }.to raise_error { |e|
        backtrace_line = "#{File.basename(__FILE__)}:#{__LINE__ - 2}"
        expect(e.message).to include("with backtrace", backtrace_line)
      }
    end

    it 'formats the backtrace using the configured backtrace formatter' do
      allow(RSpec::Matchers.configuration.backtrace_formatter).
        to receive(:format_backtrace).
        and_return("formatted-backtrace")

      expect {
        expect { raise "boom" }.not_to raise_error
      }.to raise_error { |e|
        expect(e.message).to include("with backtrace", "formatted-backtrace")
      }
    end
  end
end

describe "expect { ... }.to raise_error(message)" do
  it "passes if RuntimeError is raised with the right message" do
    expect {raise 'blah'}.to raise_error('blah')
  end

  it "passes if RuntimeError is raised with a matching message" do
    expect {raise 'blah'}.to raise_error(/blah/)
  end

  it "passes if any other error is raised with the right message" do
    expect {raise NameError.new('blah')}.to raise_error('blah')
  end

  it "fails if RuntimeError error is raised with the wrong message" do
    expect do
      expect {raise 'blarg'}.to raise_error('blah')
    end.to fail_with(/expected Exception with \"blah\", got #<RuntimeError: blarg>/)
  end

  it "fails if any other error is raised with the wrong message" do
    expect do
      expect {raise NameError.new('blarg')}.to raise_error('blah')
    end.to fail_with(/expected Exception with \"blah\", got #<NameError: blarg>/)
  end

  it 'includes the backtrace of any other error in the failure message' do
    expect {
      expect { raise "boom" }.to raise_error(ArgumentError)
    }.to raise_error { |e|
      backtrace_line = "#{File.basename(__FILE__)}:#{__LINE__ - 2}"
      expect(e.message).to include("with backtrace", backtrace_line)
    }
  end
end

describe "expect { ... }.to raise_error.with_message(message)" do
  it "raises an argument error if raise_error itself expects a message" do
    expect {
      expect { }.to raise_error("bees").with_message("sup")
    }.to raise_error.with_message(/`expect \{ \}\.to raise_error\(message\)\.with_message\(message\)` is not valid/)
  end

  it "passes if RuntimeError is raised with the right message" do
    expect {raise 'blah'}.to raise_error.with_message('blah')
  end

  it "passes if RuntimeError is raised with a matching message" do
    expect {raise 'blah'}.to raise_error.with_message(/blah/)
  end

  it "passes if any other error is raised with the right message" do
    expect {raise NameError.new('blah')}.to raise_error.with_message('blah')
  end

  it "fails if RuntimeError error is raised with the wrong message" do
    expect do
      expect {raise 'blarg'}.to raise_error.with_message('blah')
    end.to fail_with(/expected Exception with \"blah\", got #<RuntimeError: blarg>/)
  end

  it "fails if any other error is raised with the wrong message" do
    expect do
      expect {raise NameError.new('blarg')}.to raise_error.with_message('blah')
    end.to fail_with(/expected Exception with \"blah\", got #<NameError: blarg>/)
  end
end

describe "expect { ... }.not_to raise_error(message)" do
  it "is invalid" do
    expect {
      expect {raise 'blarg'}.not_to raise_error(/blah/)
    }.to raise_error(/`expect \{ \}\.not_to raise_error\(message\)` is not valid/)
  end
end

describe "expect { ... }.to raise_error(NamedError)" do
  it "passes if named error is raised" do
    expect { non_existent_method }.to raise_error(NameError)
  end

  it "fails if nothing is raised" do
    expect {
      expect { }.to raise_error(NameError)
    }.to fail_with(/expected NameError but nothing was raised/)
  end

  it "fails if another error is raised (NameError)" do
    expect {
      expect { raise RuntimeError, "example message" }.to raise_error(NameError)
    }.to fail_with(/expected NameError, got #<RuntimeError: example message>/)
  end

  it "fails if another error is raised (NameError)" do
    expect {
      expect { load "non/existent/file" }.to raise_error(NameError)
    }.to fail_with(/expected NameError, got #<LoadError/)
  end
end

describe "expect { ... }.not_to raise_error(NamedError)" do
  it "is invalid" do
    expect {
      expect { }.not_to raise_error(NameError)
    }.to raise_error(/`expect \{ \}\.not_to raise_error\(SpecificErrorClass\)` is not valid/)
  end
end

describe "expect { ... }.to raise_error(NamedError, error_message) with String" do
  it "passes if named error is raised with same message" do
    expect { raise "example message" }.to raise_error(RuntimeError, "example message")
  end

  it "fails if nothing is raised" do
    expect {
      expect {}.to raise_error(RuntimeError, "example message")
    }.to fail_with(/expected RuntimeError with \"example message\" but nothing was raised/)
  end

  it "fails if incorrect error is raised" do
    expect {
      expect { raise RuntimeError, "example message" }.to raise_error(NameError, "example message")
    }.to fail_with(/expected NameError with \"example message\", got #<RuntimeError: example message>/)
  end

  it "fails if correct error is raised with incorrect message" do
    expect {
      expect { raise RuntimeError.new("not the example message") }.to raise_error(RuntimeError, "example message")
    }.to fail_with(/expected RuntimeError with \"example message\", got #<RuntimeError: not the example message/)
  end
end

describe "expect { ... }.not_to raise_error(NamedError, error_message) with String" do
  it "is invalid" do
    expect {
      expect {}.not_to raise_error(RuntimeError, "example message")
    }.to raise_error(/`expect \{ \}\.not_to raise_error\(SpecificErrorClass, message\)` is not valid/)
  end
end

describe "expect { ... }.to raise_error(NamedError, error_message) with Regexp" do
  it "passes if named error is raised with matching message" do
    expect { raise "example message" }.to raise_error(RuntimeError, /ample mess/)
  end

  it "fails if nothing is raised" do
    expect {
      expect {}.to raise_error(RuntimeError, /ample mess/)
    }.to fail_with(/expected RuntimeError with message matching \/ample mess\/ but nothing was raised/)
  end

  it "fails if incorrect error is raised" do
    expect {
      expect { raise RuntimeError, "example message" }.to raise_error(NameError, /ample mess/)
    }.to fail_with(/expected NameError with message matching \/ample mess\/, got #<RuntimeError: example message>/)
  end

  it "fails if correct error is raised with incorrect message" do
    expect {
      expect { raise RuntimeError.new("not the example message") }.to raise_error(RuntimeError, /less than ample mess/)
    }.to fail_with(/expected RuntimeError with message matching \/less than ample mess\/, got #<RuntimeError: not the example message>/)
  end
end

describe "expect { ... }.not_to raise_error(NamedError, error_message) with Regexp" do
  it "is invalid" do
    expect {
      expect {}.not_to raise_error(RuntimeError, /ample mess/)
    }.to raise_error(/`expect \{ \}\.not_to raise_error\(SpecificErrorClass, message\)` is not valid/)
  end
end

describe "expect { ... }.to raise_error(NamedError, error_message) { |err| ... }" do
  it "yields exception if named error is raised with same message" do
    ran = false

    expect {
      raise "example message"
    }.to raise_error(RuntimeError, "example message") { |err|
      ran = true
      expect(err.class).to eq RuntimeError
      expect(err.message).to eq "example message"
    }

    expect(ran).to be(true)
  end

  it "yielded block fails on it's own right" do
    ran, passed = false, false

    expect {
      expect {
        raise "example message"
      }.to raise_error(RuntimeError, "example message") { |err|
        ran = true
        expect(5).to eq 4
        passed = true
      }
    }.to fail_with(/expected: 4/m)

    expect(ran).to    be_truthy
    expect(passed).to be_falsey
  end

  it "does NOT yield exception if no error was thrown" do
    ran = false

    expect {
      expect {}.to raise_error(RuntimeError, "example message") { |err|
        ran = true
      }
    }.to fail_with(/expected RuntimeError with \"example message\" but nothing was raised/)

    expect(ran).to eq false
  end

  it "does not yield exception if error class is not matched" do
    ran = false

    expect {
      expect {
        raise "example message"
      }.to raise_error(SyntaxError, "example message") { |err|
        ran = true
      }
    }.to fail_with(/expected SyntaxError with \"example message\", got #<RuntimeError: example message>/)

    expect(ran).to eq false
  end

  it "does NOT yield exception if error message is not matched" do
    ran = false

    expect {
      expect {
        raise "example message"
      }.to raise_error(RuntimeError, "different message") { |err|
        ran = true
      }
    }.to fail_with(/expected RuntimeError with \"different message\", got #<RuntimeError: example message>/)

    expect(ran).to eq false
  end
end

describe "expect { ... }.not_to raise_error(NamedError, error_message) { |err| ... }" do
  it "is invalid" do
    expect {
      expect {}.not_to raise_error(RuntimeError, "example message") { |err| }
    }.to raise_error(/`expect \{ \}\.not_to raise_error\(SpecificErrorClass, message\)` is not valid/)
  end
end

describe "misuse of raise_error, with (), not {}" do
  it "fails with warning" do
    expect(::Kernel).to receive(:warn).with(/`raise_error` was called with non-proc object 1\.7/)
    expect {
      expect(Math.sqrt(3)).to raise_error
    }.to fail_with(/nothing was raised/)
  end
end

describe "Composing matchers with `raise_error`" do
  matcher :an_error_with_attribute do |attr|
    chain :equal_to do |value|
      @expected_value = value
    end

    match do |error|
      error.__send__(attr) == @expected_value
    end

    description do
      super() + " equal to #{@expected_value}"
    end
  end

  class FooError < StandardError
    def foo; :bar; end
  end

  describe "expect { }.to raise_error(matcher)" do
    it 'passes when the matcher matches the raised error' do
      expect { raise FooError }.to raise_error(an_error_with_attribute(:foo).equal_to(:bar))
    end

    it 'fails with a clear message when the matcher does not match the raised error' do
      expect {
        expect { raise FooError }.to raise_error(an_error_with_attribute(:foo).equal_to(3))
      }.to fail_matching("expected an error with attribute :foo equal to 3, got #<FooError: FooError>")
    end

    it 'provides a description' do
      description = raise_error(an_error_with_attribute(:foo).equal_to(3)).description
      expect(description).to eq("raise an error with attribute :foo equal to 3")
    end
  end

  describe "expect { }.to raise_error(ErrorClass, matcher)" do
    it 'passes when the class and matcher match the raised error' do
      expect { raise FooError, "food" }.to raise_error(FooError, a_string_including("foo"))
    end

    it 'fails with a clear message when the matcher does not match the raised error' do
      expect {
        expect { raise FooError, "food" }.to raise_error(FooError, a_string_including("bar"))
      }.to fail_matching('expected FooError with a string including "bar", got #<FooError: food')
    end

    it 'provides a description' do
      description = raise_error(FooError, a_string_including("foo")).description
      expect(description).to eq('raise FooError with a string including "foo"')
    end
  end

  describe "expect { }.to raise_error(ErrorClass).with_message(matcher)" do
    it 'passes when the class and matcher match the raised error' do
      expect { raise FooError, "food" }.to raise_error(FooError).with_message(a_string_including("foo"))
    end

    it 'fails with a clear message when the matcher does not match the raised error' do
      expect {
        expect { raise FooError, "food" }.to raise_error(FooError).with_message(a_string_including("bar"))
      }.to fail_matching('expected FooError with a string including "bar", got #<FooError: food')
    end

    it 'provides a description' do
      description = raise_error(FooError).with_message(a_string_including("foo")).description
      expect(description).to eq('raise FooError with a string including "foo"')
    end
  end
end
