require "bundler"
Bundler.setup

require 'aruba'
require 'rspec/expectations'

module ArubaOverrides
  def detect_ruby_script(cmd)
    if cmd =~ /^rspec /
      "bundle exec ruby -I../../lib -S ../../bin/#{cmd}"
    else
      super(cmd)
    end
  end
end

World(ArubaOverrides)

