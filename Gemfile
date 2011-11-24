source "http://rubygems.org"

### rspec libs
%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git"
  end
end

### dev dependencies
gem "rake", "~> 0.9"
gem "cucumber", "1.0.0"
gem "aruba", "0.4.2"
gem "nokogiri", "1.4.4"

platforms :jruby do
  gem "jruby-openssl"
end

group :development do
  gem "rcov", "0.9.9", :platforms => :mri
  gem "relish", "~> 0.5.0"
  gem "guard-rspec", "0.1.9"
  gem "growl", "1.0.3"

  platforms :mri_18 do
    gem 'ruby-debug'
  end

  platforms :mri_19 do
    warn <<-EOM if RUBY_VERSION == '1.9.3'
    ruby-debug19 on ruby-1.9.3 requires gems that have not been released to
    rubygems as of 2011-11-24:

      ruby-debug-base19-0.11.26
      linecache19-0.5.13

    See http://blog.wyeworks.com/2011/11/1/ruby-1-9-3-and-ruby-debug if they
    still haven't been released and you're having trouble using ruby-debug19.
    EOM

    gem 'ruby-debug19',      '~> 0.11.6'
    gem 'ruby-debug-base19', '~> 0.11.25'
    gem 'linecache19',       '~> 0.5.12'
  end

  platforms :mri_18, :mri_19 do
    gem "rb-fsevent", "~> 0.3.9"
    gem "ruby-prof", "~> 0.9.2"
  end
end
