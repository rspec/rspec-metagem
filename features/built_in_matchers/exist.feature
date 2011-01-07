Feature: exist matcher

  The exist matcher is used to specify that something exists
  (as indicated by #exist? or #exists?):

    obj.should exist # passes if obj.exist? or obj.exists?

  Scenario Outline: basic usage
    Given a file named "exist_matcher_spec.rb" with:
      """
      class Planet
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def inspect
          "<Planet: #{name}>"
        end

        def <predicate_method>
          %w[Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune].include?(name)
        end
      end

      describe "Earth" do
        subject { Planet.new("Earth") }
        it { should exist }
        it { should_not exist } # deliberate failure
      end

      describe "Tatooine" do
        subject { Planet.new("Tatooine") }
        it { should_not exist }
        it { should exist } # deliberate failure
      end
      """
    When I run "rspec exist_matcher_spec.rb"
    Then the output should contain all of these:
      | 4 examples, 2 failures                |
      | expected <Planet: Earth> not to exist |
      | expected <Planet: Tatooine> to exist  |

    Examples:
      | predicate_method |
      | exist?           |
      | exists?          |

