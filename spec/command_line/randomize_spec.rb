require 'spec_helper'

describe 'command line' do
  describe '--randomize' do
    before :all do
      write_file 'spec/randomize_spec.rb', """
        describe 'group 1' do
          specify('example 1')  { fail }
          specify('example 2')  { fail }
          specify('example 3')  { fail }
          specify('example 4')  { fail }
          specify('example 5')  { fail }
          specify('example 6')  { fail }
          specify('example 7')  { fail }
          specify('example 8')  { fail }
          specify('example 9')  { fail }
          specify('example 10') { fail }
          specify('example 11') { fail }
          specify('example 12') { fail }
          specify('example 13') { fail }
          specify('example 14') { fail }
          specify('example 15') { fail }

          describe 'group 1-1' do
            specify('example 1')  { fail }
            specify('example 2')  { fail }
            specify('example 3')  { fail }
            specify('example 4')  { fail }
            specify('example 5')  { fail }
            specify('example 6')  { fail }
            specify('example 7')  { fail }
            specify('example 8')  { fail }
            specify('example 9')  { fail }
            specify('example 10') { fail }
            specify('example 11') { fail }
            specify('example 12') { fail }
            specify('example 13') { fail }
            specify('example 14') { fail }
            specify('example 15') { fail }

            describe 'group 1-1-1' do
              specify('example 1')  { fail }
              specify('example 2')  { fail }
              specify('example 3')  { fail }
              specify('example 4')  { fail }
              specify('example 5')  { fail }
              specify('example 6')  { fail }
              specify('example 7')  { fail }
              specify('example 8')  { fail }
              specify('example 9')  { fail }
              specify('example 10') { fail }
              specify('example 11') { fail }
              specify('example 11') { fail }
              specify('example 12') { fail }
              specify('example 13') { fail }
              specify('example 14') { fail }
              specify('example 15') { fail }
            end

            describe('group 1-1-2')  { specify('example') { fail } }
            describe('group 1-1-3')  { specify('example') { fail } }
            describe('group 1-1-4')  { specify('example') { fail } }
            describe('group 1-1-5')  { specify('example') { fail } }
            describe('group 1-1-6')  { specify('example') { fail } }
            describe('group 1-1-7')  { specify('example') { fail } }
            describe('group 1-1-8')  { specify('example') { fail } }
            describe('group 1-1-9')  { specify('example') { fail } }
            describe('group 1-1-10') { specify('example') { fail } }
            describe('group 1-1-11') { specify('example') { fail } }
            describe('group 1-1-12') { specify('example') { fail } }
            describe('group 1-1-13') { specify('example') { fail } }
            describe('group 1-1-14') { specify('example') { fail } }
            describe('group 1-1-15') { specify('example') { fail } }
          end

          describe('group 1-2')  { specify('example') { fail } }
          describe('group 1-3')  { specify('example') { fail } }
          describe('group 1-4')  { specify('example') { fail } }
          describe('group 1-5')  { specify('example') { fail } }
          describe('group 1-6')  { specify('example') { fail } }
          describe('group 1-7')  { specify('example') { fail } }
          describe('group 1-8')  { specify('example') { fail } }
          describe('group 1-9')  { specify('example') { fail } }
          describe('group 1-10') { specify('example') { fail } }
          describe('group 1-11') { specify('example') { fail } }
          describe('group 1-12') { specify('example') { fail } }
          describe('group 1-13') { specify('example') { fail } }
          describe('group 1-14') { specify('example') { fail } }
          describe('group 1-15') { specify('example') { fail } }
        end

        describe('group 2')  { specify('example') { fail } }
        describe('group 3')  { specify('example') { fail } }
        describe('group 4')  { specify('example') { fail } }
        describe('group 5')  { specify('example') { fail } }
        describe('group 6')  { specify('example') { fail } }
        describe('group 7')  { specify('example') { fail } }
        describe('group 8')  { specify('example') { fail } }
        describe('group 9')  { specify('example') { fail } }
        describe('group 10') { specify('example') { fail } }
        describe('group 11') { specify('example') { fail } }
        describe('group 12') { specify('example') { fail } }
        describe('group 13') { specify('example') { fail } }
        describe('group 14') { specify('example') { fail } }
        describe('group 15') { specify('example') { fail } }
      """
    end

    def get_failures(output, number)
      output.scan(/\s{1}#{number}\).+/).uniq
    end

    it 'runs the example groups and examples in random order' do
      3.times do
        run_simple 'rspec spec/randomize_spec.rb --randomize', false
      end
      
      1.upto(85) do |number|
        get_failures(all_stdout, number).size.should be > 1,
          "Failure messages for ##{number} are the same"
      end
    end

    context 'given a seed' do
      it 'runs the example groups and examples in the same order' do
        2.times do
          run_simple 'rspec spec/randomize_spec.rb --randomize --seed 123', false
        end

        output = only_processes.last(2).map {|p| p.stdout(@aruba_keep_ansi) }.join

        1.upto(85) do |number|
          get_failures(output, number).size.should eq(1),
            "Failure messages for ##{number} are not the same"
        end
      end
    end
  end
end
