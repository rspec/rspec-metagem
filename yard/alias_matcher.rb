require 'yard'

YARD::Handlers::Ruby::AliasHandler.class_eval do
  handles method_call(:alias_matcher)
end
