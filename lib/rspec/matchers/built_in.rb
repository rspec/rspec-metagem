module RSpec
  module Matchers
    module BuiltIn
      require 'rspec/matchers/built_in/base_matcher'
      autoload :BeAnInstanceOf, 'rspec/matchers/built_in/be_instance_of'
      autoload :Be,             'rspec/matchers/built_in/be'
      autoload :BeTrue,         'rspec/matchers/built_in/be'
      autoload :BeFalse,        'rspec/matchers/built_in/be'
      autoload :BeNil,          'rspec/matchers/built_in/be'
      autoload :BeComparedTo,   'rspec/matchers/built_in/be'
      autoload :BePredicate,    'rspec/matchers/built_in/be'
      autoload :BeAKindOf,      'rspec/matchers/built_in/be_kind_of'
      autoload :BeWithin,       'rspec/matchers/built_in/be_within'
      autoload :Change,         'rspec/matchers/built_in/change'
      autoload :Cover,          'rspec/matchers/built_in/cover' if (1..2).respond_to?(:cover?)
      autoload :Eq,             'rspec/matchers/built_in/eq'
      autoload :Eql,            'rspec/matchers/built_in/eql'
      autoload :Equal,          'rspec/matchers/built_in/equal'
      autoload :Exist,          'rspec/matchers/built_in/exist'
      autoload :Has,            'rspec/matchers/built_in/has'
      autoload :Have,           'rspec/matchers/built_in/have'
      autoload :Include,        'rspec/matchers/built_in/include'
      autoload :Match,          'rspec/matchers/built_in/match'
      autoload :MatchArray,     'rspec/matchers/built_in/match_array'
      autoload :RaiseError,     'rspec/matchers/built_in/raise_error'
      autoload :RespondTo,      'rspec/matchers/built_in/respond_to'
      autoload :Satisfy,        'rspec/matchers/built_in/satisfy'
      autoload :ThrowSymbol,    'rspec/matchers/built_in/throw_symbol'
    end
  end
end


