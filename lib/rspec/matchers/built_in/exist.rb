module RSpec
  module Matchers
    module BuiltIn
      class Exist
        include BaseMatcher

        def initialize(*args)
          super(args)
        end

        def matches?(actual)
          super(actual)
          predicates = [:exist?, :exists?].select { |p| actual.respond_to?(p) }
          existance_values = predicates.map { |p| actual.send(p, *expected) }
          uniq_truthy_values = existance_values.map { |v| !!v }.uniq

          case uniq_truthy_values.size
          when 0; raise NoMethodError.new("#{actual.inspect} does not respond to either #exist? or #exists?")
          when 1; existance_values.first
          else raise "#exist? and #exists? returned different values:\n\n" +
            " exist?: #{existance_values.first}\n" +
            "exists?: #{existance_values.last}"
          end
        end
      end
    end
  end
end
