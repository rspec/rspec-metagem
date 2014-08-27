module RSpec
  module Core
    module Formatters
      # ConsoleCodes provides helpers for formatting console output
      # with ANSI codes, e.g. color's and bold.
      module ConsoleCodes
        # @private
        VT100_CODES =
          {
            :black   => 30,
            :red     => 31,
            :green   => 32,
            :yellow  => 33,
            :blue    => 34,
            :magenta => 35,
            :cyan    => 36,
            :white   => 37,
            :bold    => 1,
          }
        # @private
        VT100_CODE_VALUES = VT100_CODES.invert

        module_function

        # Fetches the correct code for the supplied symbol, or checks
        # that a code is valid. Defaults to white (37).
        #
        # @param code_or_symbol [Symbol, Fixnum] Symbol or code to check
        # @return [Fixnum] a console code
        def console_code_for(code_or_symbol)
          if RSpec.configuration.respond_to?(:"#{code_or_symbol}_color")
            console_code_for configuration_color(code_or_symbol)
          elsif VT100_CODE_VALUES.key?(code_or_symbol)
            code_or_symbol
          else
            VT100_CODES.fetch(code_or_symbol) do
              console_code_for(:white)
            end
          end
        end

        # Wraps a piece of text in ANSI codes with the supplied code. Will
        # only apply the control code if `RSpec.configuration.color_enabled?`
        # returns true.
        #
        # @param text [String] the text to wrap
        # @param code_or_symbol [Symbol, Fixnum] the desired control code
        # @return [String] the wrapped text
        def wrap(text, code_or_symbol)
          if RSpec.configuration.color_enabled?
            "\e[#{console_code_for(code_or_symbol)}m#{text}\e[0m"
          else
            text
          end
        end

        # @private
        def configuration_color(code)
          RSpec.configuration.__send__(:"#{code}_color")
        end
      end
    end
  end
end
