module RSpecHelpers
  def relative_path(path)
    RSpec::Core::Metadata.relative_path(path)
  end

  def safely
    Thread.new do
      $SAFE = 3
      yield
    end.join
    $SAFE.should == 0  # just to be safe ;-)
  end

end
