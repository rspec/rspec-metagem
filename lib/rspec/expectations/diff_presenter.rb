require 'diff/lcs'
require "rspec/expectations/encoded_string"
require 'diff/lcs/hunk'
require 'pp'

module RSpec
  module Expectations
    class DiffPresenter
      def diff_as_string(actual, expected)
        @encoding = pick_encoding actual, expected

        @actual   = EncodedString.new(actual, encoding)
        @expected = EncodedString.new(expected, encoding)

        output = EncodedString.new("\n", encoding)

        hunks.each_cons(2) do |prev_hunk, current_hunk|
          begin
            if current_hunk.overlaps?(prev_hunk)
              add_old_hunk_to_hunk(current_hunk, prev_hunk)
            else
              add_to_output(output, prev_hunk.diff(format).to_s)
            end
          ensure
            add_to_output(output, "\n")
          end
        end

        if hunks.last
          finalize_output(output, hunks.last.diff(format).to_s)
        end

        color_diff output
      rescue Encoding::CompatibilityError
        handle_encoding_errors
      end

      def diff_as_object(actual, expected)
        actual_as_string = object_to_string(actual)
        expected_as_string = object_to_string(expected)
        if diff = diff_as_string(actual_as_string, expected_as_string)
          color_diff diff
        end
      end

      private

      attr_reader :expected, :actual, :encoding

      def hunks
        @file_length_difference = 0
        @hunks ||= diffs.map do |piece|
          build_hunk(piece)
        end
      end

      def finalize_output(output, final_line)
        add_to_output(output, final_line)
        add_to_output(output, "\n")
      end

      def hunk_diff_string(hunk)
        hunk.diff(format).to_s
      end

      def add_to_output(output, string)
        output << string
      end

      def add_old_hunk_to_hunk(hunk, oldhunk)
        if hunk.respond_to?(:merge)
          # diff-lcs 1.2.x
          hunk.merge(oldhunk)
        else
          # diff-lcs 1.1.3
          hunk.unshift(oldhunk)
        end
      end

      def build_hunk(piece)
        Diff::LCS::Hunk.new(
          expected_lines, actual_lines, piece, context_lines, @file_length_difference
        ).tap do |h|
          @file_length_difference = h.file_length_difference
        end
      end

      def diffs
        Diff::LCS.diff(expected_lines, actual_lines)
      end

      def expected_lines
        expected.split("\n").map! { |e| e.chomp }
      end

      def actual_lines
        actual.split("\n").map! { |e| e.chomp }
      end

      def format
        :unified
      end

      def context_lines
        3
      end

      def color(text, color_code)
        "\e[#{color_code}m#{text}\e[0m"
      end

      def red(text)
        color(text, 31)
      end

      def green(text)
        color(text, 32)
      end

      def blue(text)
        color(text, 34)
      end

      def color_diff(diff)
        return diff unless RSpec::Matchers.configuration.color?

        diff.lines.map { |line|
          case line[0].chr
          when "+"
            green line
          when "-"
            red line
          when "@"
            line[1].chr == "@" ? blue(line) : line
          else
            line
          end
        }.join
      end

      def object_to_string(object)
        case object
        when Hash
          object.keys.sort_by { |k| k.to_s }.map do |key|
            pp_key   = PP.singleline_pp(key, "")
            pp_value = PP.singleline_pp(object[key], "")

            "#{pp_key} => #{pp_value}"
          end.join(",\n")
        when String
          object =~ /\n/ ? object : object.inspect
        else
          PP.pp(object,"")
        end
      end

      if String.method_defined?(:encoding)
        def pick_encoding(source_a, source_b)
          Encoding.compatible?(source_a, source_b) || Encoding.default_external
        end
      else
        def pick_encoding(source_a, source_b)
        end
      end

      def handle_encoding_errors
        if actual.encoding != expected.encoding
          "Could not produce a diff because the encoding of the actual string (#{expected.encoding}) "+
            "differs from the encoding of the expected string (#{actual.encoding})"
        else
          "Could not produce a diff because of the encoding of the string (#{expected.encoding})"
        end
      end
    end
  end
end

