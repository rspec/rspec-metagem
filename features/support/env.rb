require 'aruba'
require 'rspec/expectations'

module ArubaOverrides
  def detect_ruby_script(cmd)
    if cmd =~ /^rspec /
      "../../bin/#{cmd}"
    else
      super(cmd)
    end
  end
end

World(ArubaOverrides)

