module RSpec # :nodoc:
  module Core # :nodoc:
    module Version # :nodoc:
      STRING = File.readlines(File.expand_path('../../../../VERSION', __FILE__)).first
    end
  end
end
