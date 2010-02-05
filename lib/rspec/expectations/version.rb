module Rspec # :nodoc:
  module Expectations # :nodoc:
    module Version # :nodoc:
      unless defined?(MAJOR)
        MAJOR  = 2
        MINOR  = 0
        TINY   = 0
        PRE    = 'a4'

        STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

        SUMMARY = "rspec-expectations " + STRING
      end
    end
  end
end
