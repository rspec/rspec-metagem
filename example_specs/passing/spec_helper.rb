lib_path = File.expand_path("#{File.dirname(__FILE__)}/../../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
require 'rspec/autorun'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '/../../../expectations/lib'))
require 'rspec/expectations'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '/../../../mocks/lib'))
require 'rspec/mocks'

Rspec::Core::ExampleGroup.send(:include, Rspec::Matchers)

Rspec::Core.configure do |c|
  c.mock_with :rspec
  c.color_enabled = true
end
