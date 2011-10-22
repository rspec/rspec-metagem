require 'spec_helper'

describe 'command line' do
  before :all do
    write_file 'spec/randomize_spec.rb', """
      describe 'group 1' do
        specify('group 1 example 1')  {}
        specify('group 1 example 2')  {}
        specify('group 1 example 3')  {}
        specify('group 1 example 4')  {}
        specify('group 1 example 5')  {}
        specify('group 1 example 6')  {}
        specify('group 1 example 7')  {}
        specify('group 1 example 8')  {}
        specify('group 1 example 9')  {}
        specify('group 1 example 10') {}
        specify('group 1 example 11') {}
        specify('group 1 example 12') {}
        specify('group 1 example 13') {}
        specify('group 1 example 14') {}
        specify('group 1 example 15') {}
        specify('group 1 example 16') {}
        specify('group 1 example 17') {}
        specify('group 1 example 18') {}
        specify('group 1 example 19') {}
        specify('group 1 example 20') {}

        describe 'group 1-1' do
          specify('group 1-1 example 1')  {}
          specify('group 1-1 example 2')  {}
          specify('group 1-1 example 3')  {}
          specify('group 1-1 example 4')  {}
          specify('group 1-1 example 5')  {}
          specify('group 1-1 example 6')  {}
          specify('group 1-1 example 7')  {}
          specify('group 1-1 example 8')  {}
          specify('group 1-1 example 9')  {}
          specify('group 1-1 example 10') {}
          specify('group 1-1 example 11') {}
          specify('group 1-1 example 12') {}
          specify('group 1-1 example 13') {}
          specify('group 1-1 example 14') {}
          specify('group 1-1 example 15') {}
          specify('group 1-1 example 16') {}
          specify('group 1-1 example 17') {}
          specify('group 1-1 example 18') {}
          specify('group 1-1 example 19') {}
          specify('group 1-1 example 20') {}
        end

        describe('group 1-2')  { specify('example') {} }
        describe('group 1-3')  { specify('example') {} }
        describe('group 1-4')  { specify('example') {} }
        describe('group 1-5')  { specify('example') {} }
        describe('group 1-6')  { specify('example') {} }
        describe('group 1-7')  { specify('example') {} }
        describe('group 1-8')  { specify('example') {} }
        describe('group 1-9')  { specify('example') {} }
        describe('group 1-10') { specify('example') {} }
        describe('group 1-11') { specify('example') {} }
        describe('group 1-12') { specify('example') {} }
        describe('group 1-13') { specify('example') {} }
        describe('group 1-14') { specify('example') {} }
        describe('group 1-15') { specify('example') {} }
        describe('group 1-16') { specify('example') {} }
        describe('group 1-17') { specify('example') {} }
        describe('group 1-18') { specify('example') {} }
        describe('group 1-19') { specify('example') {} }
        describe('group 1-20') { specify('example') {} }
      end

      describe('group 2')  { specify('example') {} }
      describe('group 3')  { specify('example') {} }
      describe('group 4')  { specify('example') {} }
      describe('group 5')  { specify('example') {} }
      describe('group 6')  { specify('example') {} }
      describe('group 7')  { specify('example') {} }
      describe('group 8')  { specify('example') {} }
      describe('group 9')  { specify('example') {} }
      describe('group 10') { specify('example') {} }
      describe('group 11') { specify('example') {} }
      describe('group 12') { specify('example') {} }
      describe('group 13') { specify('example') {} }
      describe('group 14') { specify('example') {} }
      describe('group 15') { specify('example') {} }
      describe('group 16') { specify('example') {} }
      describe('group 17') { specify('example') {} }
      describe('group 18') { specify('example') {} }
      describe('group 19') { specify('example') {} }
      describe('group 20') { specify('example') {} }
    """
  end

  def assert_randomized(array)
    split_in_two(array)[0].should_not eq(split_in_two(array)[1])
  end

  def assert_not_randomized(array)
    split_in_two(array)[0].should eq(split_in_two(array)[1])
  end

  def split_in_two(array)
    length, half = array.length, array.length / 2
    [array.slice(0, half), array.slice(half, length)]
  end

  def example_groups(level)
    all_stdout.scan(/^\s{#{level}}group.*$/)
  end

  def examples(group)
    all_stdout.scan(/^\s+#{group} example.*$/)
  end

  describe '--randomize' do
    it 'runs the example groups and examples in random order' do
      2.times do
        run_simple 'rspec spec/randomize_spec.rb --randomize -f doc', false
      end

      assert_randomized example_groups(0)
      assert_randomized example_groups(2)
      assert_randomized examples('group 1')
      assert_randomized examples('group 1-1')

      all_stdout.should match(
        /This run was randomized by the following seed: \d+/
      )
    end
  end

  describe '--seed' do
    it 'runs the example groups and examples in the same order' do
      2.times do
        run_simple 'rspec spec/randomize_spec.rb --seed 123 -f doc', false
      end

      assert_not_randomized example_groups(0)
      assert_not_randomized example_groups(2)
      assert_not_randomized examples('group 1')
      assert_not_randomized examples('group 1-1')

      all_stdout.should match(
        /This run was randomized by the following seed: 123/
      )
    end
  end
end
