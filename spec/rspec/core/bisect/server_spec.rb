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

    context "when results are failed to be reported" do
      let(:server) { Bisect::Server.new }

      it "raises an error with the output" do
        expect {
          server.capture_run_results { "the output" }
        }.to raise_error(an_object_having_attributes(
          :class      => Bisect::Server::DidNotGetRunResults,
          :run_output => "the output"
        ))
      end
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

      describe "aborting the run early" do
        it "aborts as soon as the last expected failure finishes, since we don't care about what happens after that" do
          expected_failures = %w[
            ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
            ./spec/rspec/core/resources/formatter_specs.rb[4:1]
          ]

          results = server.capture_run_results(expected_failures) do
            run_formatter_specs
          end

          expect(results).to have_attributes(
            :all_example_ids => %w[
              ./spec/rspec/core/resources/formatter_specs.rb[1:1]
              ./spec/rspec/core/resources/formatter_specs.rb[2:1:1]
              ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
              ./spec/rspec/core/resources/formatter_specs.rb[3:1]
              ./spec/rspec/core/resources/formatter_specs.rb[4:1]
            ],
            :failed_example_ids => %w[
              ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
              ./spec/rspec/core/resources/formatter_specs.rb[4:1]
            ]
          )
        end

        it 'aborts after an expected failure passes instead, even when there are remaining failing examples' do
          passing_example       = "./spec/rspec/core/resources/formatter_specs.rb[3:1]"
          later_failing_example = "./spec/rspec/core/resources/formatter_specs.rb[4:1]"

          results = server.capture_run_results([passing_example, later_failing_example]) do
            run_formatter_specs
          end

          expect(results).to have_attributes(
            :all_example_ids => %w[
              ./spec/rspec/core/resources/formatter_specs.rb[1:1]
              ./spec/rspec/core/resources/formatter_specs.rb[2:1:1]
              ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
              ./spec/rspec/core/resources/formatter_specs.rb[3:1]
            ],
            :failed_example_ids => %w[
              ./spec/rspec/core/resources/formatter_specs.rb[2:2:1]
            ]
          )
        end

        it 'aborts after an expected failure is pending instead, even when there are remaining failing examples' do
          pending_example       = "./spec/rspec/core/resources/formatter_specs.rb[1:1]"
          later_failing_example = "./spec/rspec/core/resources/formatter_specs.rb[4:1]"

          results = server.capture_run_results([pending_example, later_failing_example]) do
            run_formatter_specs
          end

          expect(results).to have_attributes(
            :all_example_ids    => %w[ ./spec/rspec/core/resources/formatter_specs.rb[1:1] ],
            :failed_example_ids => %w[]
          )
        end
      end
    end
  end
end
