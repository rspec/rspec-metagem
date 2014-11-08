require_relative "helper"

benchmark_allocations do
  1000.times do |i|
    RSpec.describe "group #{i}" do
      it "has one example" do
      end
    end
  end
end

__END__

Original allocations:

               class_plus                 count
----------------------------------------  -----
String                                    28000
Array                                     15000
RubyVM::Env                                9000
Proc                                       9000
Hash                                       9000
RSpec::Core::Hooks::HookCollection         6000
Array<String>                              5000
MatchData                                  3000
Array<String,Fixnum>                       2000
Array<Module>                              2000
Module                                     2000
RSpec::Core::Example::ExecutionResult      2000
RSpec::Core::Metadata::ExampleGroupHash    1000
Class                                      1000
Array<Hash>                                1000
RSpec::Core::Hooks::AroundHookCollection   1000
RSpec::Core::Hooks::HookCollections        1000
RSpec::Core::Metadata::ExampleHash         1000
RSpec::Core::Example                       1000
Array<RSpec::Core::Example>                1000


After removing `:suite` support from `Hooks` module,
it cut Array and RSpec::Core::Hooks::HookCollection
allocations by 2000 each:

               class_plus                 count
----------------------------------------  -----
String                                    28000
Array                                     13000
Proc                                       9000
RubyVM::Env                                9000
Hash                                       9000
Array<String>                              5000
RSpec::Core::Hooks::HookCollection         4000
MatchData                                  3000
Array<Module>                              2000
RSpec::Core::Example::ExecutionResult      2000
Module                                     2000
Array<String,Fixnum>                       2000
RSpec::Core::Hooks::HookCollections        1000
RSpec::Core::Example                       1000
Array<RSpec::Core::Example>                1000
RSpec::Core::Metadata::ExampleHash         1000
RSpec::Core::Hooks::AroundHookCollection   1000
RSpec::Core::Metadata::ExampleGroupHash    1000
Class                                      1000
Array<Hash>                                1000
