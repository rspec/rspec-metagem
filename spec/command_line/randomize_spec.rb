require 'spec_helper'

describe 'command line', :ui do
  before :all do
    write_file 'spec/randomize_spec.rb', """
      describe 'group 1' do
        specify('group 1 example 1')  {}
        specify('group 1 example 2')  {}
        specify('group 1 example 3')  {}
        specify('group 1 example 4')  {}
        specify('group 1 example 5')  {}

        describe 'group 1-1' do
          specify('group 1-1 example 1')  {}
          specify('group 1-1 example 2')  {}
          specify('group 1-1 example 3')  {}
          specify('group 1-1 example 4')  {}
          specify('group 1-1 example 5')  {}
        end

        describe('group 1-2')  { specify('example') {} }
        describe('group 1-3')  { specify('example') {} }
        describe('group 1-4')  { specify('example') {} }
        describe('group 1-5')  { specify('example') {} }
      end

      describe('group 2')  { specify('example') {} }
      describe('group 3')  { specify('example') {} }
      describe('group 4')  { specify('example') {} }
      describe('group 5')  { specify('example') {} }
    """
  end

  describe '--randomize' do
    it 'runs the examples and groups in a different order each time' do
      2.times { run_command 'rspec spec/randomize_spec.rb --randomize -f doc' }

      top_level_groups      {|first_run, second_run| first_run.should_not eq(second_run)}
      nested_groups         {|first_run, second_run| first_run.should_not eq(second_run)}
      examples('group 1')   {|first_run, second_run| first_run.should_not eq(second_run)}
      examples('group 1-1') {|first_run, second_run| first_run.should_not eq(second_run)}

      all_stdout.should match(
        /This run was randomized by the following seed: \d+/
      )
    end
  end

  describe '--seed' do
    it 'runs the examples and groups in the same order each time' do
      2.times { run_command 'rspec spec/randomize_spec.rb --seed 123 -f doc' }

      top_level_groups      {|first_run, second_run| first_run.should eq(second_run)}
      nested_groups         {|first_run, second_run| first_run.should eq(second_run)}
      examples('group 1')   {|first_run, second_run| first_run.should eq(second_run)}
      examples('group 1-1') {|first_run, second_run| first_run.should eq(second_run)}

      all_stdout.should match(
        /This run was randomized by the following seed: 123/
      )
    end
  end

  def examples(group)
    yield split_in_half(all_stdout.scan(/^\s+#{group} example.*$/))
  end

  def top_level_groups
    yield example_groups_at_level(0)
  end

  def nested_groups
    yield example_groups_at_level(2)
  end

  def example_groups_at_level(level)
    split_in_half(all_stdout.scan(/^\s{#{level*2}}group.*$/))
  end

  def split_in_half(array)
    length, midpoint = array.length, array.length / 2
    return array.slice(0, midpoint), array.slice(midpoint, length)
  end

  def run_command(cmd)
    # Wraps aruba api - 2nd param is fail_on_error
    run_simple cmd, false
  end
end
