require 'spec_helper'

module RSpec
  describe CallerFilter do
    def ruby_files_in_lib(lib)
      # http://rubular.com/r/HYpUMftlG2
      path = $LOAD_PATH.find { |p| p.match(/\/rspec-#{lib}(-[a-f0-9]+)?\/lib/) }

      Dir["#{path}/**/*.rb"].sort.tap do |files|
        # Just a sanity check...
        expect(files.count).to be > 10
      end
    end

    describe "the filtering regex" do
      def unmatched_from(files)
        files.reject { |file| file.match(CallerFilter::LIB_REGEX) }
      end

      %w[ core mocks expectations ].each do |lib|
        it "matches all ruby files in rspec-#{lib}" do
          files     = ruby_files_in_lib(lib)

          # We don't care about this file -- it only has a single require statement
          # and won't show up in any backtraces.
          files.reject! { |file| file.end_with?('lib/rspec-expectations.rb') }

          expect(unmatched_from files).to eq([])
        end
      end

      it "does not match other ruby files" do
        files = %w[
          /path/to/lib/rspec/some-extension/foo.rb
          /path/to/spec/rspec/core/some_spec.rb
        ]

        expect(unmatched_from files).to eq(files)
      end
    end
  end
end

