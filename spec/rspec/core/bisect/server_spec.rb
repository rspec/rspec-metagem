require 'rspec/core/bisect/server'
require 'support/formatter_support'

module RSpec::Core
  RSpec.describe Bisect::Server do
    RSpec::Matchers.define :have_running_server do
      match do |drb|
        begin
          drb.current_server.alive?
        rescue DRb::DRbServerNotFound
          false
        end
      end
    end

    it 'always stops the server, even if an error occurs while yielding' do
      expect(DRb).not_to have_running_server

      expect {
        Bisect::Server.run do
          expect(DRb).to have_running_server
          raise "boom"
        end
      }.to raise_error("boom")

      expect(DRb).not_to have_running_server
    end

    context "when used in combination with the BisectFormatter", :slow do
      include FormatterSupport

      attr_reader :server

      around do |ex|
        Bisect::Server.run do |the_server|
          @server = the_server
          ex.run
        end
      end

      def run_formatter_specs
        RSpec.configuration.drb_port = server.drb_port
        run_example_specs_with_formatter("bisect")
      end

      it 'receives suite results' do
        results = server.capture_run_results do
          run_formatter_specs
        end

        expect(results).to have_attributes(
          :all_example_ids => %w[
            ./spec/rspec/core/resources/formatter_specs.rb[1:1]
            ./spec/rspec/core/resources/formatter_specs.rb[2:1:1]
            ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
            ./spec/rspec/core/resources/formatter_specs.rb[3:1]
            ./spec/rspec/core/resources/formatter_specs.rb[4:1]
            ./spec/rspec/core/resources/formatter_specs.rb[5:1]
            ./spec/rspec/core/resources/formatter_specs.rb[5:2]
          ],
          :failed_example_ids => %w[
            ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
            ./spec/rspec/core/resources/formatter_specs.rb[4:1]
            ./spec/rspec/core/resources/formatter_specs.rb[5:1]
            ./spec/rspec/core/resources/formatter_specs.rb[5:2]
          ]
        )
      end

      it 'can abort the run early (e.g. when it is not interested in later examples)' do
        results = server.capture_run_results("./spec/rspec/core/resources/formatter_specs.rb[2:2:1]") do
          run_formatter_specs
        end

        expect(results).to have_attributes(
          :all_example_ids => %w[
            ./spec/rspec/core/resources/formatter_specs.rb[1:1]
            ./spec/rspec/core/resources/formatter_specs.rb[2:1:1]
            ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
          ],
          :failed_example_ids => %w[
            ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
          ]
        )
      end

      # TODO: test aborting after pending vs failed vs passing example if we keep this feature.
    end
  end
end
