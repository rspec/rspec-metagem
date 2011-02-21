Feature: User-defined metadata

  You can attach user-defined metadata to any example group or example.
  Pass a hash as the last argument (before the block) to `describe`,
  `context` or `it`.  RSpec supports many configuration options that apply
  only to certain examples or groups based on the metadata.

  Metadata defined on an example group is available (and can be overriden)
  by any sub-group or from any example in that group or a sub-group.

  Scenario: define group metadata using a hash
    Given a file named "define_group_metadata_with_hash_spec.rb" with:
      """
      describe "a group with user-defined metadata", :foo => 17 do
        it 'has access to the metadata in the example' do
          example.metadata[:foo].should == 17
        end

        it 'does not have access to metadata defined on sub-groups' do
          example.metadata.should_not include(:bar)
        end

        describe 'a sub-group with user-defined metadata', :bar => 12 do
          it 'has access to the sub-group metadata' do
            example.metadata[:foo].should == 17
          end

          it 'also has access to metadata defined on parent groups' do
            example.metadata[:bar].should == 12
          end
        end
      end
      """
    When I run "rspec define_group_metadata_with_hash_spec.rb"
    Then the examples should all pass

  Scenario: define example metadata using a hash
    Given a file named "define_example_metadata_with_hash_spec.rb" with:
      """
      describe "a group with no user-defined metadata" do
        it 'has an example with metadata', :foo => 17 do
          example.metadata[:foo].should == 17
          example.metadata.should_not include(:bar)
        end

        it 'has another example with metadata', :bar => 12, :bazz => 33 do
          example.metadata[:bar].should == 12
          example.metadata[:bazz].should == 33
          example.metadata.should_not include(:foo)
        end
      end
      """
    When I run "rspec define_example_metadata_with_hash_spec.rb"
    Then the examples should all pass

  Scenario: override user-defined metadata
    Given a file named "override_metadata_spec.rb" with:
      """
      describe "a group with user-defined metadata", :foo => 'bar' do
        it 'can be overriden by an example', :foo => 'bazz' do
          example.metadata[:foo].should == 'bazz'
        end

        describe "a sub-group with an override", :foo => 'goo' do
          it 'can be overriden by a sub-group' do
            example.metadata[:foo].should == 'goo'
          end
        end
      end
      """
    When I run "rspec override_metadata_spec.rb"
    Then the examples should all pass
