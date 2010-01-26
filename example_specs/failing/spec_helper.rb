lib_path = File.expand_path('../../../lib', __FILE__)
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
require 'rspec/autorun'
require 'rspec/expectations'

Rspec::Core.configure do |c|
  c.include Rspec::Matchers
end
