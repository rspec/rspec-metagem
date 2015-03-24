require 'rspec/core/project_initializer'

module RSpec::Core
  RSpec.describe OptionParser do
    before do
      allow(RSpec.configuration).to receive(:reporter) do
        fail "OptionParser is not allowed to access `config.reporter` since we want " +
             "ConfigurationOptions to have the chance to set `deprecation_stream` " +
             "(based on `--deprecation-out`) before the deprecation formatter is " +
             "initialized by the reporter instantiation. If you need to issue a deprecation, " +
             "populate an `options[:deprecations]` key and have ConfigurationOptions " +
             "issue the deprecation after configuring `deprecation_stream`"
      end
    end

    context "when given empty args" do
      it "does not parse them" do
        expect(OptionParser).not_to receive(:new)
        Parser.parse([])
      end

      it "still returns a `:files_or_directories_to_run` entry since callers expect that" do
        expect(
          Parser.parse([])
        ).to eq(:files_or_directories_to_run => [])
      end
    end

    it 'does not mutate the provided args array' do
      args = %w[ --require foo ]
      expect { Parser.parse(args) }.not_to change { args }
    end

    it "proposes you to use --help and returns an error on incorrect argument" do
      parser = Parser.new([option = "--my_wrong_arg"])

      expect(parser).to receive(:abort) do |msg|
        expect(msg).to include('use --help', option)
      end

      parser.parse
    end

    it 'treats additional arguments as `:files_or_directories_to_run`' do
      options = Parser.parse(%w[ path/to/spec.rb --fail-fast spec/unit -Ibar 1_spec.rb:23 ])
      expect(options).to include(
        :files_or_directories_to_run => %w[ path/to/spec.rb spec/unit 1_spec.rb:23 ]
      )
    end

    {
      '--init'         => ['-i','--I'],
      '--default-path' => ['-d'],
      '--dry-run'      => ['-d'],
      '--drb-port'     => ['-d'],
    }.each do |long, shorts|
      shorts.each do |option|
        it "won't parse #{option} as a shorthand for #{long}" do
          parser = Parser.new([option])

          expect(parser).to receive(:abort) do |msg|
            expect(msg).to include('use --help', option)
          end

          parser.parse
        end
      end
    end

    it "won't display invalid options in the help output" do
      def generate_help_text
        parser = Parser.new(["--help"])
        allow(parser).to receive(:exit)
        parser.parse
      end

      useless_lines = /^\s*--?\w+\s*$\n/

      expect { generate_help_text }.to_not output(useless_lines).to_stdout
    end

    %w[ -v --version ].each do |option|
      describe option do
        it "prints the version and exits" do
          parser = Parser.new([option])
          expect(parser).to receive(:exit)

          expect {
            parser.parse
          }.to output("#{RSpec::Core::Version::STRING}\n").to_stdout
        end
      end
    end

    describe "--init" do
      it "initializes a project and exits" do
        project_init = instance_double(ProjectInitializer)
        allow(ProjectInitializer).to receive_messages(:new => project_init)

        parser = Parser.new(["--init"])

        expect(project_init).to receive(:run).ordered
        expect(parser).to receive(:exit).ordered

        parser.parse
      end
    end

    describe "-I" do
      it "sets the path" do
        options = Parser.parse(%w[-I path/to/foo])
        expect(options[:libs]).to eq %w[path/to/foo]
      end

      context "with a string containing `#{File::PATH_SEPARATOR}`" do
        it "splits into multiple paths, just like Ruby's `-I` option" do
          options = Parser.parse(%W[-I path/to/foo -I path/to/bar#{File::PATH_SEPARATOR}path/to/baz])
          expect(options[:libs]).to eq %w[path/to/foo path/to/bar path/to/baz]
        end
      end
    end

    describe "--default-path" do
      it "sets the default path where RSpec looks for examples" do
        options = Parser.parse(%w[--default-path foo])
        expect(options[:default_path]).to eq "foo"
      end
    end

    %w[--format -f].each do |option|
      describe option do
        it "defines the formatter" do
          options = Parser.parse([option, 'doc'])
          expect(options[:formatters].first).to eq(["doc"])
        end
      end
    end

    %w[--out -o].each do |option|
      describe option do
        it "sets the output stream for the formatter" do
          options = Parser.parse([option, 'out.txt'])
          expect(options[:formatters].last).to eq(['progress', 'out.txt'])
        end

        context "with multiple formatters" do
          context "after last formatter" do
            it "sets the output stream for the last formatter" do
              options = Parser.parse(['-f', 'progress', '-f', 'doc', option, 'out.txt'])
              expect(options[:formatters][0]).to eq(['progress'])
              expect(options[:formatters][1]).to eq(['doc', 'out.txt'])
            end
          end

          context "after first formatter" do
            it "sets the output stream for the first formatter" do
              options = Parser.parse(['-f', 'progress', option, 'out.txt', '-f', 'doc'])
              expect(options[:formatters][0]).to eq(['progress', 'out.txt'])
              expect(options[:formatters][1]).to eq(['doc'])
            end
          end
        end
      end
    end

    describe "--deprecation-out" do
      it 'sets the deprecation stream' do
        options = Parser.parse(["--deprecation-out", "path/to/log"])
        expect(options).to include(:deprecation_stream => "path/to/log")
      end
    end

    describe "--only-failures" do
      it 'is equivalent to `--tag last_run_status:failed`' do
        tag = Parser.parse(%w[ --tag last_run_status:failed ])
        only_failures = Parser.parse(%w[ --only-failures ])

        expect(only_failures).to include(tag)
      end
    end

    describe "--next-failure" do
      it 'is equivalent to `--tag last_run_status:failed --fail-fast --order defined`' do
        long_form = Parser.parse(%w[ --tag last_run_status:failed --fail-fast --order defined ])
        next_failure = Parser.parse(%w[ --next-failure ])

        expect(next_failure).to include(long_form)
      end

      it 'does not force `--order defined` over a specified `--seed 1234` option that comes before it' do
        options = Parser.parse(%w[ --seed 1234 --next-failure ])
        expect(options).to include(:order => "rand:1234")
      end

      it 'does not force `--order defined` over a specified `--seed 1234` option that comes after it' do
        options = Parser.parse(%w[ --next-failure --seed 1234 ])
        expect(options).to include(:order => "rand:1234")
      end
    end

    %w[--example -e].each do |option|
      describe option do
        it "escapes the arg" do
          options = Parser.parse([option, "this (and that)"])
          expect(options[:full_description].length).to eq(1)
          expect("this (and that)").to match(options[:full_description].first)
        end
      end
    end

    %w[--pattern -P].each do |option|
      describe option do
        it "sets the filename pattern" do
          options = Parser.parse([option, 'spec/**/*.spec'])
          expect(options[:pattern]).to eq('spec/**/*.spec')
        end
      end
    end

    %w[--tag -t].each do |option|
      describe option do
        context "without ~" do
          it "treats no value as true" do
            options = Parser.parse([option, 'foo'])
            expect(options[:inclusion_filter]).to eq(:foo => true)
          end

          it "treats 'true' as true" do
            options = Parser.parse([option, 'foo:true'])
            expect(options[:inclusion_filter]).to eq(:foo => true)
          end

          it "treats 'nil' as nil" do
            options = Parser.parse([option, 'foo:nil'])
            expect(options[:inclusion_filter]).to eq(:foo => nil)
          end

          it "treats 'false' as false" do
            options = Parser.parse([option, 'foo:false'])
            expect(options[:inclusion_filter]).to eq(:foo => false)
          end

          it "merges muliple invocations" do
            options = Parser.parse([option, 'foo:false', option, 'bar:true', option, 'foo:true'])
            expect(options[:inclusion_filter]).to eq(:foo => true, :bar => true)
          end

          it "treats 'any_string' as 'any_string'" do
            options = Parser.parse([option, 'foo:any_string'])
            expect(options[:inclusion_filter]).to eq(:foo => 'any_string')
          end

          it "treats ':any_sym' as :any_sym" do
            options = Parser.parse([option, 'foo::any_sym'])
            expect(options[:inclusion_filter]).to eq(:foo => :any_sym)
          end

          it "treats '42' as 42" do
            options = Parser.parse([option, 'foo:42'])
            expect(options[:inclusion_filter]).to eq(:foo => 42)
          end

          it "treats '3.146' as 3.146" do
            options = Parser.parse([option, 'foo:3.146'])
            expect(options[:inclusion_filter]).to eq(:foo => 3.146)
          end
        end

        context "with ~" do
          it "treats no value as true" do
            options = Parser.parse([option, '~foo'])
            expect(options[:exclusion_filter]).to eq(:foo => true)
          end

          it "treats 'true' as true" do
            options = Parser.parse([option, '~foo:true'])
            expect(options[:exclusion_filter]).to eq(:foo => true)
          end

          it "treats 'nil' as nil" do
            options = Parser.parse([option, '~foo:nil'])
            expect(options[:exclusion_filter]).to eq(:foo => nil)
          end

          it "treats 'false' as false" do
            options = Parser.parse([option, '~foo:false'])
            expect(options[:exclusion_filter]).to eq(:foo => false)
          end
        end
      end
    end

    describe "--order" do
      it "is nil by default" do
        expect(Parser.parse([])[:order]).to be_nil
      end

      %w[rand random].each do |option|
        context "with #{option}" do
          it "defines the order as random" do
            options = Parser.parse(['--order', option])
            expect(options[:order]).to eq(option)
          end
        end
      end
    end

    describe "--seed" do
      it "sets the order to rand:SEED" do
        options = Parser.parse(%w[--seed 123])
        expect(options[:order]).to eq("rand:123")
      end
    end

    describe '--profile' do
      it 'sets profile_examples to true by default' do
        options = Parser.parse(%w[--profile])
        expect(options[:profile_examples]).to eq true
      end

      it 'sets profile_examples to supplied int' do
        options = Parser.parse(%w[--profile 10])
        expect(options[:profile_examples]).to eq 10
      end

      it 'sets profile_examples to true when accidentally combined with path' do
        allow_warning
        options = Parser.parse(%w[--profile some/path])
        expect(options[:profile_examples]).to eq true
      end

      it 'warns when accidentally combined with path' do
        expect_warning_without_call_site "Non integer specified as profile count"
        options = Parser.parse(%w[--profile some/path])
        expect(options[:profile_examples]).to eq true
      end
    end

    describe '--warning' do
      around do |ex|
        verbose = $VERBOSE
        ex.run
        $VERBOSE = verbose
      end

      it 'immediately enables warnings so that warnings are issued for files loaded by `--require`' do
        $VERBOSE = false

        expect {
          Parser.parse(%w[--warnings])
        }.to change { $VERBOSE }.from(false).to(true)
      end
    end

  end
end
