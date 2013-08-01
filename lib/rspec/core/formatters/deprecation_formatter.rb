module RSpec
  module Core
    module Formatters
      module DeprecationFormatter
        class Base < Struct.new(:deprecation_stream, :summary_stream)
          def deprecation(data)
            if data[:message]
              deprecation_stream.print data[:message]
            else
              print_deprecation_message(data)
            end
          end

          def print_deprecation_message(data)
            deprecation_stream.puts deprecation_message(data)
          end

          def deprecation_message(data)
            msg =  "#{data[:deprecated]} is deprecated."
            msg << " Use #{data[:replacement]} instead." if data[:replacement]
            msg << " Called from #{data[:call_site]}." if data[:call_site]
            msg
          end
        end

        class FileDeprecationFormatter < Base
          def initialize(*_)
            super
            @count = 0
          end

          def deprecation(data)
            super
            @count += 1
          end

          def deprecation_summary
            if @count > 0
              summary_stream.print "\n#{@count} deprecation"
              summary_stream.print "s" if @count > 1
              summary_stream.print " logged to "
              summary_stream.puts deprecation_stream.path
            end
          end
        end

        class IODeprecationFormatter < Base
          def initialize(*_)
            super
            @seen_deprecations = Hash.new { 0 }
          end

          def print_deprecation_message(data)
            @seen_deprecations[data[:deprecated]] += 1

            if @seen_deprecations[data[:deprecated]] <= 3
              deprecation_stream.puts "DEPRECATION: #{deprecation_message(data)}"
            elsif @seen_deprecations[data[:deprecated]] == 4
              deprecation_stream.print "DEPRECATION: Too many uses of deprecated '#{data[:deprecated]}'."
              deprecation_stream.puts  " Set config.deprecation_stream to a File for full output"
            end
          end
        end

        class << self
          def [](deprecation_stream=$stderr, summary_stream=$stdout)
            if File === deprecation_stream
              FileDeprecationFormatter.new(deprecation_stream, summary_stream)
            else
              IODeprecationFormatter.new(deprecation_stream, summary_stream)
            end
          end
        end
      end
    end
  end
end
