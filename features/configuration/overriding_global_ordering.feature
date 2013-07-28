Feature: Overriding global ordering

  Scenario: running a specific examples group in order
    Given a file named "order_dependent_spec.rb" with:
      """ruby
      describe "examples only pass when they are run in order", :order => :default do
        before(:all) { @list = [] }

        it "passes when run first" do
          @list << 1
          expect(@list).to eq([1])
        end

        it "passes when run second" do
          @list << 2
          expect(@list).to eq([1, 2])
        end

        it "passes when run third" do
          @list << 3
          expect(@list).to eq([1, 2, 3])
        end
      end
      """

    When I run `rspec order_dependent_spec.rb --order random:1 --format documentation`
    Then the examples should all pass
    And the output should contain:
      """
      examples only pass when they are run in order
        passes when run first
        passes when run second
        passes when run third
      """
