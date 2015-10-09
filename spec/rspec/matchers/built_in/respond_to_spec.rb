RSpec.describe "expect(...).to respond_to(:sym)" do
  it_behaves_like "an RSpec matcher", :valid_value => "s", :invalid_value => 5 do
    let(:matcher) { respond_to(:upcase) }
  end

  it "passes if target responds to :sym" do
    expect(Object.new).to respond_to(:methods)
  end

  it "fails if target does not respond to :sym" do
    expect {
      expect("this string").to respond_to(:some_method)
    }.to fail_with(%q|expected "this string" to respond to :some_method|)
  end
end

RSpec.describe "expect(...).to respond_to(:sym).with(1).argument" do
  it "passes if target responds to :sym with 1 arg" do
    obj = Object.new
    def obj.foo(arg); end
    expect(obj).to respond_to(:foo).with(1).argument
  end

  it "passes if target responds to any number of arguments" do
    obj = Object.new
    def obj.foo(*args); end
    expect(obj).to respond_to(:foo).with(1).argument
  end

  it "passes if target responds to one or more arguments" do
    obj = Object.new
    def obj.foo(a, *args); end
    expect(obj).to respond_to(:foo).with(1).argument
  end

  it "fails if target does not respond to :sym" do
    obj = Object.new
    expect {
      expect(obj).to respond_to(:some_method).with(1).argument
    }.to fail_with(/expected .* to respond to :some_method/)
  end

  it "fails if :sym expects 0 args" do
    obj = Object.new
    def obj.foo; end
    expect {
      expect(obj).to respond_to(:foo).with(1).argument
    }.to fail_with(/expected #<Object.*> to respond to :foo with 1 argument/)
  end

  it "fails if :sym expects 2 args" do
    obj = Object.new
    def obj.foo(arg, arg2); end
    expect {
      expect(obj).to respond_to(:foo).with(1).argument
    }.to fail_with(/expected #<Object.*> to respond to :foo with 1 argument/)
  end

  it "fails if :sym expects 2 or more args" do
    obj = Object.new
    def obj.foo(arg, arg2, *args); end
    expect {
      expect(obj).to respond_to(:foo).with(1).argument
    }.to fail_with(/expected #<Object.*> to respond to :foo with 1 argument/)
  end

  it "still works if target has overridden the method method" do
    obj = Object.new
    def obj.method; end
    def obj.other_method(arg); end
    expect(obj).to respond_to(:other_method).with(1).argument
  end
end

RSpec.describe "expect(...).to respond_to(message1, message2)" do
  it "passes if target responds to both messages" do
    expect(Object.new).to respond_to('methods', 'inspect')
  end

  it "fails if target does not respond to first message" do
    expect {
      expect(Object.new).to respond_to('method_one', 'inspect')
    }.to fail_with(/expected #<Object:.*> to respond to "method_one"/)
  end

  it "fails if target does not respond to second message" do
    expect {
      expect(Object.new).to respond_to('inspect', 'method_one')
    }.to fail_with(/expected #<Object:.*> to respond to "method_one"/)
  end

  it "fails if target does not respond to either message" do
    expect {
      expect(Object.new).to respond_to('method_one', 'method_two')
    }.to fail_with(/expected #<Object:.*> to respond to "method_one", "method_two"/)
  end
end

RSpec.describe "expect(...).to respond_to(:sym).with(2).arguments" do
  it "passes if target responds to :sym with 2 args" do
    obj = Object.new
    def obj.foo(a1, a2); end
    expect(obj).to respond_to(:foo).with(2).arguments
  end

  it "passes if target responds to any number of arguments" do
    obj = Object.new
    def obj.foo(*args); end
    expect(obj).to respond_to(:foo).with(2).arguments
  end

  it "passes if target responds to one or more arguments" do
    obj = Object.new
    def obj.foo(a, *args); end
    expect(obj).to respond_to(:foo).with(2).arguments
  end

  it "passes if target responds to two or more arguments" do
    obj = Object.new
    def obj.foo(a, b, *args); end
    expect(obj).to respond_to(:foo).with(2).arguments
  end

  it "fails if target does not respond to :sym" do
    obj = Object.new
    expect {
      expect(obj).to respond_to(:some_method).with(2).arguments
    }.to fail_with(/expected .* to respond to :some_method/)
  end

  it "fails if :sym expects 0 args" do
    obj = Object.new
    def obj.foo; end
    expect {
      expect(obj).to respond_to(:foo).with(2).arguments
    }.to fail_with(/expected #<Object.*> to respond to :foo with 2 arguments/)
  end

  it "fails if :sym expects 1 args" do
    obj = Object.new
    def obj.foo(arg); end
    expect {
      expect(obj).to respond_to(:foo).with(2).arguments
    }.to fail_with(/expected #<Object.*> to respond to :foo with 2 arguments/)
  end

  it "fails if :sym expects 3 or more args" do
    obj = Object.new
    def obj.foo(arg, arg2, arg3, *args); end
    expect {
      expect(obj).to respond_to(:foo).with(2).arguments
    }.to fail_with(/expected #<Object.*> to respond to :foo with 2 arguments/)
  end
end

RSpec.describe "expect(...).to respond_to(:sym).with_unlimited_arguments" do
  it "passes if target responds to any number of arguments" do
    obj = Object.new
    def obj.foo(*args); end
    expect(obj).to respond_to(:foo).with_unlimited_arguments
  end

  it "passes if target responds to a minimum number of arguments" do
    obj = Object.new
    def obj.foo(arg, arg2, arg3, *args); end
    expect(obj).to respond_to(:foo).with(3).arguments.and_unlimited_arguments
  end

  it "fails if target does not respond to :sym" do
    obj = Object.new
    expect {
      expect(obj).to respond_to(:some_method).with_unlimited_arguments
    }.to fail_with(/expected .* to respond to :some_method/)
  end

  it "fails if :sym expects a minimum number of arguments" do
    obj = Object.new
    def obj.some_method(arg, arg2, arg3, *args); end
    expect {
      expect(obj).to respond_to(:some_method).with_unlimited_arguments
    }.to fail_with(/expected .* to respond to :some_method with unlimited arguments/)
  end

  it "fails if :sym expects a limited number of arguments" do
    obj = Object.new
    def obj.some_method(arg); end
    expect {
      expect(obj).to respond_to(:some_method).with_unlimited_arguments
    }.to fail_with(/expected .* to respond to :some_method with unlimited arguments/)
  end
end

RSpec.describe "expect(...).not_to respond_to(:sym)" do
  it "passes if target does not respond to :sym" do
    expect(Object.new).not_to respond_to(:some_method)
  end

  it "fails if target responds to :sym" do
    expect {
      expect(Object.new).not_to respond_to(:methods)
    }.to fail_with(/expected #<Object:.*> not to respond to :methods/)
  end
end

RSpec.describe "expect(...).not_to respond_to(:sym).with(1).argument" do
  it "fails if target responds to :sym with 1 arg" do
    obj = Object.new
    def obj.foo(arg); end
    expect {
      expect(obj).not_to respond_to(:foo).with(1).argument
    }.to fail_with(/expected #<Object:.*> not to respond to :foo with 1 argument/)
  end

  it "fails if target responds to :sym with any number of args" do
    obj = Object.new
    def obj.foo(*args); end
    expect {
      expect(obj).not_to respond_to(:foo).with(1).argument
    }.to fail_with(/expected #<Object:.*> not to respond to :foo with 1 argument/)
  end

  it "fails if target responds to :sym with one or more args" do
    obj = Object.new
    def obj.foo(a, *args); end
    expect {
      expect(obj).not_to respond_to(:foo).with(1).argument
    }.to fail_with(/expected #<Object:.*> not to respond to :foo with 1 argument/)
  end

  it "passes if target does not respond to :sym" do
    obj = Object.new
    expect(obj).not_to respond_to(:some_method).with(1).argument
  end

  it "passes if :sym expects 0 args" do
    obj = Object.new
    def obj.foo; end
    expect(obj).not_to respond_to(:foo).with(1).argument
  end

  it "passes if :sym expects 2 args" do
    obj = Object.new
    def obj.foo(arg, arg2); end
    expect(obj).not_to respond_to(:foo).with(1).argument
  end

  it "passes if :sym expects 2 or more args" do
    obj = Object.new
    def obj.foo(arg, arg2, *args); end
    expect(obj).not_to respond_to(:foo).with(1).argument
  end
end

RSpec.describe "expect(...).not_to respond_to(message1, message2)" do
  it "passes if target does not respond to either message1 or message2" do
    expect(Object.new).not_to respond_to(:some_method, :some_other_method)
  end

  it "fails if target responds to message1 but not message2" do
    expect {
      expect(Object.new).not_to respond_to(:object_id, :some_method)
    }.to fail_with(/expected #<Object:.*> not to respond to :object_id/)
  end

  it "fails if target responds to message2 but not message1" do
    expect {
      expect(Object.new).not_to respond_to(:some_method, :object_id)
    }.to fail_with(/expected #<Object:.*> not to respond to :object_id/)
  end

  it "fails if target responds to both message1 and message2" do
    expect {
      expect(Object.new).not_to respond_to(:class, :object_id)
    }.to fail_with(/expected #<Object:.*> not to respond to :class, :object_id/)
  end
end

RSpec.describe "expect(...).not_to respond_to(:sym).with(2).arguments" do
  it "fails if target responds to :sym with 2 args" do
    obj = Object.new
    def obj.foo(a1, a2); end
    expect {
      expect(obj).not_to respond_to(:foo).with(2).arguments
    }.to fail_with(/expected .* not to respond to :foo with 2 arguments/)
  end

  it "fails if target responds to :sym with any number args" do
    obj = Object.new
    def obj.foo(*args); end
    expect {
      expect(obj).not_to respond_to(:foo).with(2).arguments
    }.to fail_with(/expected .* not to respond to :foo with 2 arguments/)
  end

  it "fails if target responds to :sym with one or more args" do
    obj = Object.new
    def obj.foo(a, *args); end
    expect {
      expect(obj).not_to respond_to(:foo).with(2).arguments
    }.to fail_with(/expected .* not to respond to :foo with 2 arguments/)
  end

  it "fails if target responds to :sym with two or more args" do
    obj = Object.new
    def obj.foo(a, b, *args); end
    expect {
      expect(obj).not_to respond_to(:foo).with(2).arguments
    }.to fail_with(/expected .* not to respond to :foo with 2 arguments/)
  end

  it "passes if target does not respond to :sym" do
    obj = Object.new
    expect(obj).not_to respond_to(:some_method).with(2).arguments
  end

  it "passes if :sym expects 0 args" do
    obj = Object.new
    def obj.foo; end
    expect(obj).not_to respond_to(:foo).with(2).arguments
  end

  it "passes if :sym expects 2 args" do
    obj = Object.new
    def obj.foo(arg); end
    expect(obj).not_to respond_to(:foo).with(2).arguments
  end

  it "passes if :sym expects 3 or more args" do
    obj = Object.new
    def obj.foo(a, b, c, *arg); end
    expect(obj).not_to respond_to(:foo).with(2).arguments
  end
end

RSpec.describe "expect(...).not_to respond_to(:sym).with_unlimited_arguments" do
  it "fails if target responds to :sym with any number args" do
    obj = Object.new
    def obj.foo(*args); end
    expect {
      expect(obj).not_to respond_to(:foo).with_unlimited_arguments
    }.to fail_with(/expected .* not to respond to :foo with unlimited arguments/)
  end

  it "passes if target does not respond to :sym" do
    obj = Object.new
    expect(obj).not_to respond_to(:some_method).with_unlimited_arguments
  end

  it "passes if :sym expects a limited number of arguments" do
    obj = Object.new
    def obj.some_method(arg); end
    expect(obj).not_to respond_to(:some_method).with_unlimited_arguments
  end

  it "passes if :sym expects a minimum number of arguments" do
    obj = Object.new
    def obj.some_method(arg, arg2, arg3, *args); end
    expect(obj).not_to respond_to(:some_method).with_unlimited_arguments
  end
end

if RSpec::Support::RubyFeatures.kw_args_supported?
  RSpec.describe "expect(...).to respond_to(:sym).with_keywords(:foo, :bar)" do
    it 'passes if target responds to :sym with specified optional keywords' do
      obj = Object.new
      eval %{def obj.foo(a: nil, b: nil); end}
      expect(obj).to respond_to(:foo).with_keywords(:a, :b)
    end

    it 'passes if target responds to :sym with any keywords' do
      obj = Object.new
      eval %{def obj.foo(**kw_args); end}
      expect(obj).to respond_to(:foo).with_keywords(:a, :b)
    end

    it "fails if target does not respond to :sym" do
      obj = Object.new
      expect {
        expect(obj).to respond_to(:some_method).with_keywords(:a, :b)
      }.to fail_with(/expected .* to respond to :some_method with keywords :a and :b/)
    end

    it "fails if :sym does not expect specified keywords" do
      obj = Object.new
      def obj.foo; end
      expect {
        expect(obj).to respond_to(:foo).with_keywords(:a, :b)
      }.to fail_with(/expected .* to respond to :foo with keywords :a and :b/)
    end

    if RSpec::Support::RubyFeatures.required_kw_args_supported?
      it "passes if target responds to :sym with specified required keywords" do
        obj = Object.new
        eval %{def obj.foo(a:, b:, c: nil, d: nil); end}
        expect(obj).to respond_to(:foo).with_keywords(:a, :b)
      end

      it "passes if target responds to :sym with keyword arg splat" do
        obj = Object.new
        eval %{def obj.foo(**rest); end}
        expect(obj).to respond_to(:foo).with_keywords(:a, :b)
      end

      it "fails if :sym expects specified optional keywords but expects missing required keywords" do
        obj = Object.new
        eval %{def obj.foo(a:, b:, c: nil, d: nil); end}
        expect {
          expect(obj).to respond_to(:some_method).with_keywords(:c, :d)
        }.to fail_with(/expected .* to respond to :some_method with keywords :c and :d/)
      end

      it "fails if target responds to :sym with keyword arg splat but missing required keywords" do
        obj = Object.new
        eval %{def obj.foo(a:, b:, **rest); end}
        expect {
          expect(obj).to respond_to(:some_method).with_keywords(:c, :d)
        }.to fail_with(/expected .* to respond to :some_method with keywords :c and :d/)
      end
    end
  end

  RSpec.describe "expect(...).to respond_to(:sym).with(2).arguments.and_keywords(:foo, :bar)" do
    it "passes if target responds to :sym with 2 args and specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(a, b, u: nil, v: nil); end}
      expect(obj).to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
    end

    it "passes if target responds to :sym with any number of arguments and specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(*args, u: nil, v: nil); end}
      expect(obj).to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
    end

    it "passes if target responds to :sym with one or more arguments and specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(a, *args, u: nil, v: nil); end}
      expect(obj).to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
    end

    it "passes if target responds to :sym with two or more arguments and specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(a, b, *args, u: nil, v: nil); end}
      expect(obj).to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
    end

    it "fails if target does not respond to :sym" do
      obj = Object.new
      expect {
        expect(obj).to respond_to(:some_method).with(2).arguments.and_keywords(:u, :v)
      }.to fail_with(/expected .* to respond to :some_method with 2 arguments and keywords :u and :v/)
    end

    it "fails if :sym expects 1 argument" do
      obj = Object.new
      eval %{def obj.foo(a, u: nil, v: nil); end}
      expect {
        expect(obj).to respond_to(:some_method).with(2).arguments.and_keywords(:u, :v)
      }.to fail_with(/expected .* to respond to :some_method with 2 arguments and keywords :u and :v/)
    end

    it "fails if :sym does not expect specified keywords" do
      obj = Object.new
      def obj.foo(a, b); end
      expect {
        expect(obj).to respond_to(:some_method).with(2).arguments.and_keywords(:u, :v)
      }.to fail_with(/expected .* to respond to :some_method with 2 arguments and keywords :u and :v/)
    end

    if RSpec::Support::RubyFeatures.required_kw_args_supported?
      it "passes if target responds to :sym with 2 args and specified required keywords" do
        obj = Object.new
        eval %{def obj.foo(a, b, u:, v:); end}
        expect(obj).to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
      end

      it "passes if target responds to :sym with 2 args and keyword arg splat" do
        obj = Object.new
        eval %{def obj.foo(a, b, **rest); end}
        expect(obj).to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
      end

      it "fails if :sym expects 2 arguments and specified optional keywords but expects missing required keywords" do
        obj = Object.new
        eval %{def obj.foo(a, b, u: nil, v: nil, x:, y:); end}
        expect {
          expect(obj).to respond_to(:some_method).with(2).arguments.and_keywords(:u, :v)
        }.to fail_with(/expected .* to respond to :some_method with 2 arguments and keywords :u and :v/)
      end
    end
  end

  RSpec.describe "expect(...).to respond_to(:sym).with_any_keywords" do
    it "passes if target responds to any keywords" do
      obj = Object.new
      eval %{def obj.foo(**kw_args); end}
      expect(obj).to respond_to(:foo).with_any_keywords
    end

    it "fails if target does not respond to :sym" do
      obj = Object.new
      expect {
        expect(obj).to respond_to(:some_method).with_any_keywords
      }.to fail_with(/expected .* to respond to :some_method/)
    end

    it "fails if :sym expects a limited set of keywords" do
      obj = Object.new
      eval %{def obj.some_method(a: nil, b: nil); end}
      expect {
        expect(obj).to respond_to(:some_method).with_any_keywords
      }.to fail_with(/expected .* to respond to :some_method with any keywords/)
    end

    if RSpec::Support::RubyFeatures.required_kw_args_supported?
      it "fails if :sym expects missing required keywords" do
        obj = Object.new
        eval %{def obj.some_method(a:, b:, **kw_args); end}
        expect {
          expect(obj).to respond_to(:some_method).with_any_keywords
        }.to fail_with(/expected .* to respond to :some_method with any keywords/)
      end
    end
  end

  RSpec.describe "expect(...).not_to respond_to(:sym).with_keywords(:foo, :bar)" do
    it "fails if target responds to :sym with specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(a: nil, b: nil); end}
      expect {
        expect(obj).not_to respond_to(:foo).with_keywords(:a, :b)
      }.to fail_with(/expected #<Object:.*> not to respond to :foo with keywords :a and :b/)
    end

    it "fails if target responds to :sym with any keywords" do
      obj = Object.new
      eval %{def obj.foo(**kw_args); end}
      expect {
        expect(obj).not_to respond_to(:foo).with_keywords(:a, :b)
      }.to fail_with(/expected #<Object:.*> not to respond to :foo with keywords :a and :b/)
    end

    it "passes if target does not respond to :sym" do
      obj = Object.new
      expect(obj).not_to respond_to(:some_method).with_keywords(:a, :b)
    end

    it "passes if :sym does not expect specified keywords" do
      obj = Object.new
      eval %{def obj.foo(a: nil, b: nil); end}
      expect(obj).not_to respond_to(:some_method).with_keywords(:c, :d)
    end

    if RSpec::Support::RubyFeatures.required_kw_args_supported?
      it "fails if target responds to :sym with specified required keywords" do
        obj = Object.new
        eval %{def obj.foo(a:, b:); end}
        expect {
          expect(obj).not_to respond_to(:foo).with_keywords(:a, :b)
        }.to fail_with(/expected #<Object:.*> not to respond to :foo with keywords :a and :b/)
      end

      it "fails if target responds to :sym with keyword arg splat" do
        obj = Object.new
        eval %{def obj.foo(**rest); end}
        expect {
          expect(obj).not_to respond_to(:foo).with_keywords(:a, :b)
        }.to fail_with(/expected #<Object:.*> not to respond to :foo with keywords :a and :b/)
      end

      it "passes if :sym expects missing required keywords" do
        obj = Object.new
        eval %{def obj.foo(a:, b:, c: nil, d: nil); end}
        expect(obj).not_to respond_to(:some_method).with_keywords(:c, :d)
      end
    end
  end

  RSpec.describe "expect(...).not_to respond_to(:sym).with(2).arguments.and_keywords(:foo, :bar)" do
    it "fails if target responds to :sym with 2 args and specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(a, b, u: nil, v: nil); end}
      expect {
        expect(obj).not_to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
      }.to fail_with(/expected #<Object:.*> not to respond to :foo with 2 arguments and keywords :u and :v/)
    end

    it "fails if target responds to :sym with any number of arguments and specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(*args, u: nil, v: nil); end}
      expect {
        expect(obj).not_to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
      }.to fail_with(/expected #<Object:.*> not to respond to :foo with 2 arguments and keywords :u and :v/)
    end

    it "fails if target responds to :sym with one or more arguments and specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(a, *args, u: nil, v: nil); end}
      expect {
        expect(obj).not_to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
      }.to fail_with(/expected #<Object:.*> not to respond to :foo with 2 arguments and keywords :u and :v/)
    end

    it "fails if target responds to :sym with two or more arguments and specified optional keywords" do
      obj = Object.new
      eval %{def obj.foo(a, b, *args, u: nil, v: nil); end}
      expect {
        expect(obj).not_to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
      }.to fail_with(/expected #<Object:.*> not to respond to :foo with 2 arguments and keywords :u and :v/)
    end

    it "passes if target does not respond to :sym" do
      obj = Object.new
      expect(obj).not_to respond_to(:some_method).with(2).arguments.and_keywords(:u, :v)
    end

    it "passes if :sym expects 1 argument" do
      obj = Object.new
      eval %{def obj.foo(a, u: nil, v: nil); end}
      expect(obj).not_to respond_to(:some_method).with(2).arguments.and_keywords(:u, :v)
    end

    it "passes if :sym does not expect specified keywords" do
      obj = Object.new
      def obj.foo(a, b); end
      expect(obj).not_to respond_to(:some_method).with(2).arguments.and_keywords(:u, :v)
    end

    if RSpec::Support::RubyFeatures.required_kw_args_supported?
      it "fails if target responds to :sym with 2 args and specified required keywords" do
        obj = Object.new
        eval %{def obj.foo(a, b, u:, v:); end}
        expect {
          expect(obj).not_to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
        }.to fail_with(/expected #<Object:.*> not to respond to :foo with 2 arguments and keywords :u and :v/)
      end

      it "fails if target responds to :sym with 2 args and keyword arg splat" do
        obj = Object.new
        eval %{def obj.foo(a, b, **rest); end}
        expect {
          expect(obj).not_to respond_to(:foo).with(2).arguments.and_keywords(:u, :v)
        }.to fail_with(/expected #<Object:.*> not to respond to :foo with 2 arguments and keywords :u and :v/)
      end

      it "passes if :sym expects 2 arguments and specified optional keywords but expects missing required keywords" do
        obj = Object.new
        eval %{def obj.foo(a, b, u: nil, v: nil, x:, y:); end}
        expect(obj).not_to respond_to(:some_method).with(2).arguments.and_keywords(:u, :v)
      end
    end
  end

  RSpec.describe "expect(...).not_to respond_to(:sym).with_any_keywords" do
    it "fails if target responds to any keywords" do
      obj = Object.new
      eval %{def obj.foo(**kw_args); end}
      expect {
        expect(obj).not_to respond_to(:foo).with_any_keywords
      }.to fail_with(/expected #<Object:.*> not to respond to :foo with any keywords/)
    end

    it "passes if target does not respond to :sym" do
      obj = Object.new
      expect(obj).not_to respond_to(:some_method).with_any_keywords
    end

    it "passes if :sym expects a limited set of keywords" do
      obj = Object.new
      eval %{def obj.some_method(a: nil, b: nil); end}
      expect(obj).not_to respond_to(:some_method).with_any_keywords
    end

    if RSpec::Support::RubyFeatures.required_kw_args_supported?
      it "passes if :sym expects missing required keywords" do
        obj = Object.new
        eval %{def obj.some_method(a:, b:, **kw_args); end}
        expect(obj).not_to respond_to(:some_method).with_any_keywords
      end
    end
  end
end
