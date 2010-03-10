begin
  require 'diff/lcs'
rescue LoadError
  raise "You must gem install diff-lcs to use diffing"
end

require 'diff/lcs/hunk'
