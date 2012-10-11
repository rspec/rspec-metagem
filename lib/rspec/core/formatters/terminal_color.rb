module RSpec
  module Core
    module Formatters
      class TerminalColor
        
        VT100_COLORS = {
          :black => 30,
          :red => 31,
          :green => 32,
          :yellow => 33,
          :blue => 34,
          :magenta => 35,
          :cyan => 36,
          :white => 37
        }
        
        def self.colorize(text, code_or_symbol)
          code = VT100_COLORS.fetch(code_or_symbol) { code_or_symbol }
          "\e[#{code}m#{text}\e[0m"
        end
      end
    end
  end
end