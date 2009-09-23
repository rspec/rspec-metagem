RSPEC_LIB = File.expand_path(File.join(File.dirname(__FILE__),'..','..','lib'))

require 'forwardable'
require 'tempfile'
require 'spec/ruby_forker'
require 'features/support/matchers/smart_match'

class RspecWorld
  include Rspec::Expectations
  include Rspec::Matchers
  include RubyForker

  extend Forwardable
  def_delegators RspecWorld, :working_dir, :spec_command
  
  def self.working_dir
    @working_dir ||= File.expand_path(File.join(File.dirname(__FILE__),'..','..','tmp','cucumber-generated-files'))
  end

  def self.spec_command
    @spec_command ||= File.expand_path(File.join(File.dirname(__FILE__),'..','..','bin','rspec'))
  end

  
  def spec(args)
    ruby("#{spec_command} #{args}")
  end

  def create_file(file_name, contents)
    file_path = File.join(working_dir, file_name)
    File.open(file_path, "w") { |f| f << contents }
  end

  def last_stdout
    @stdout
  end

  def last_stderr
    @stderr
  end

  def last_exit_code
    @exit_code
  end
  
  def rspec_libs
    "-I #{RSPEC_LIB}"
  end

  # it seems like this, and the last_* methods, could be moved into RubyForker-- is that being used anywhere but the features?
  def ruby(args)
    stderr_file = Tempfile.new('rspec')
    stderr_file.close
    Dir.chdir(working_dir) do
      @stdout = super("-rrubygems #{rspec_libs} #{args}", stderr_file.path)
    end
    @stderr = IO.read(stderr_file.path)
    @exit_code = $?.to_i
  end

end

Before do
  FileUtils.rm_rf   RspecWorld.working_dir if test ?d, RspecWorld.working_dir
  FileUtils.mkdir_p RspecWorld.working_dir
end

World do
  RspecWorld.new
end
