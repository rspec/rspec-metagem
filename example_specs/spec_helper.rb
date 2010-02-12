$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../../rspec-expectations/lib', __FILE__)
$LOAD_PATH << File.expand_path('../../../rspec-mocks/lib', __FILE__)
require 'rspec/expectations'
require 'rspec/autorun'

Rspec.configure do |c|
  c.mock_with :rspec
  c.include Rspec::Matchers
end

