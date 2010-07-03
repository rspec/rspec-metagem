# require 'spec_helper'

begin # See rescue all the way at the bottom

  require 'nokogiri' # Needed to compare generated with wanted HTML
  require 'rspec/core/formatters/html_formatter'

  module RSpec
    module Core
      module Formatters
        describe HtmlFormatter do

          def jruby?
            ::RUBY_PLATFORM == 'java'
          end

          attr_reader :root, :expected_file, :expected_html

          before do
            @root = File.expand_path("#{File.dirname(__FILE__)}/../../../..")
            suffix = jruby? ? '-jruby' : ''
            @expected_file = "#{File.dirname(__FILE__)}/html_formatted-#{::RUBY_VERSION}#{suffix}.html"
            raise "There is no HTML file with expected content for this platform: #{expected_file}" unless File.file?(expected_file)
            @expected_html = File.read(expected_file)
          end

          let(:generated_html) do
            seconds = /\d+\.\d+ seconds/
            html = `bundle exec rspec spec/rspec/core/resources/formatter_specs.rb --format html`
            html.gsub seconds, 'x seconds'
          end

          # Uncomment this line temporarily in order to overwrite the expected with actual.
          # Use with care!!!
          # describe "file generator" do
            # it "generates a new comparison file" do
              # Dir.chdir(root) do
                # File.open(expected_file, 'w') {|io| io.write(generated_html)}
              # end
            # end
          # end

          it "should produce HTML identical to the one we designed manually" do
            Dir.chdir(root) do
              actual_doc = Nokogiri::HTML(generated_html)
              actual_backtraces = actual_doc.search("div.backtrace").collect {|e| e.at("pre").inner_html}
              actual_doc.css("div.backtrace").remove

              expected_doc = Nokogiri::HTML(expected_html)
              expected_backtraces = expected_doc.search("div.backtrace").collect {|e| e.at("pre").inner_html}
              expected_doc.search("div.backtrace").remove

              actual_doc.inner_html.should == expected_doc.inner_html

              expected_backtraces.each_with_index do |expected_line, i|
                expected_path, expected_line_number, expected_suffix = expected_line.split(':')
                actual_path, actual_line_number, actual_suffix = actual_backtraces[i].split(':')
                File.expand_path(actual_path).should == File.expand_path(expected_path)
                actual_line_number.should == expected_line_number
              end
            end
          end
        end
      end
    end
  end

rescue LoadError
  warn "nokogiri not loaded -- skipping HtmlFormatter specs"
end
