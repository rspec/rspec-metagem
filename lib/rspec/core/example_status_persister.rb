module RSpec
  module Core
    class ExampleStatusPersister
    end

    # Dumps a list of hashes in a pretty, human readable format
    # for later parsing. The hashes are expected to have symbol
    # keys and string values, and each hash should have the same
    # set of keys.
    # @private
    class ExampleStatusDumper
      def self.dump(examples)
        new(examples).dump
      end

      def initialize(examples)
        @examples = examples
      end

      def dump
        return nil if @examples.empty?
        (formatted_header_rows + formatted_value_rows).join("\n") << "\n"
      end

    private

      def formatted_header_rows
        @formatted_header_rows ||= begin
          dividers = column_widths.map { |w| "-" * w }
          [formatted_row_from(headers.map(&:to_s)), formatted_row_from(dividers)]
        end
      end

      def formatted_value_rows
        @foramtted_value_rows ||= rows.map do |row|
          formatted_row_from(row)
        end
      end

      def rows
        @rows ||= @examples.map { |ex| ex.values_at(*headers) }
      end

      def formatted_row_from(row_values)
        padded_values = row_values.each_with_index.map do |value, index|
          value.ljust(column_widths[index])
        end

        padded_values.join(" | ") << " |"
      end

      def headers
        @headers ||= @examples.first.keys
      end

      def column_widths
        @column_widths ||= begin
          value_sets = rows.transpose

          headers.each_with_index.map do |header, index|
            values = value_sets[index] << header.to_s
            values.map(&:length).max
          end
        end
      end
    end

    # Parses a string that has been previously dumped by ExampleStatusDumper.
    # Note that this parser is a bit naive in that it does a simple split on
    # "\n" and " | ", with no concern for handling escaping. For now, that's
    # OK because the values we plan to persist (example id, status, and perhaps
    # example duration) are highly unlikely to contain "\n" or " | " -- after
    # all, who puts those in file names?
    # @private
    class ExampleStatusParser
      def self.parse(string)
        new(string).parse
      end

      def initialize(string)
        @header_line, _, *@row_lines = string.lines.to_a
      end

      def parse
        @row_lines.map { |line| parse_row(line) }
      end

    private

      def parse_row(line)
        Hash[headers.zip(split_line(line))]
      end

      def headers
        @headers ||= split_line(@header_line).map(&:to_sym)
      end

      def split_line(line)
        line.split(/\s+\|\s+/)
      end
    end
  end
end
