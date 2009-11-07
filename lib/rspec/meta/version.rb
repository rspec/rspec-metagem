module Rspec # :nodoc:
  module Meta # :nodoc:
    module Version # :nodoc:
      unless defined?(MAJOR)
        MAJOR  = 2
        MINOR  = 0
        TINY   = 0
        PRE    = 'a1'

        STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

        SUMMARY = "rspec-meta " + STRING
      end
    end
  end
end
