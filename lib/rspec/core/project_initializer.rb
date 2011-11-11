module RSpec
  module Core
    class ProjectInitializer
      attr_reader :command

      def initialize(cmd)
        @command = cmd
      end

      def run
        FileUtils.mkdir_p 'spec'
        File.open 'spec/spec_helper.rb', 'w+' do |file|
          file.write <<-FILE
require 'rspec'

RSpec.configure do |c|
  c.mock_with :rspec
end
          FILE
        end
        File.open 'spec/example_spec.rb', 'w+' do |file|
          file.write <<-FILE
require 'spec_helper'

describe 'example' do

  # let(:test_data) { 'testo' }

  # before do
  #   some_setup_stuff
  # end

  # context 'doing something' do
  #   it 'should behave like i want to' do
  #     it.should be_true
  #   end
  # end
  
  pending 'please remove this example and add your own spec!'

end
        FILE
        end
        
        puts 'now run: rspec spec'
      end
    end
  end
end
