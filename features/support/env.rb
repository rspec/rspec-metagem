$LOAD_PATH << File.expand_path("../../../../rspec-expectations/lib", __FILE__)
require 'rspec/expectations'
require 'aruba'

module ArubaOverrides
  def detect_ruby_script(cmd)
    if cmd =~ /^rspec /
      "ruby -I../../lib -S ../../bin/#{cmd}"
    else
      super(cmd)
    end
  end
end

World(ArubaOverrides)

