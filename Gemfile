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
gem "rake", "~> 0.9.2"
gem "cucumber", "1.0.1"
gem "aruba", "0.4.2"
gem "ZenTest", "4.6.2"
gem "nokogiri", "1.5.0"
gem "fakefs", "0.4.0", :require => "fakefs/safe"

platforms :jruby do
  gem "jruby-openssl"
end

### rspec-core only
gem "mocha", "~> 0.9.10"
gem "rr", "~> 1.0.2"
gem "flexmock", "0.8.8"

### optional runtime deps
gem "syntax", "1.0.0"

group :development do
  gem 'interactive_rspec'
  gem 'yard'
  gem "relish", "~> 0.5.0"
  gem "guard-rspec", "0.5.0"
  gem "growl", "1.0.3"
  gem "spork", "0.9.0.rc9"

  platforms :mri_18, :jruby do
    gem "rcov", "0.9.10"
  end

  platforms :mri_18 do
    gem 'ruby-debug'
  end

  platforms :mri_19 do
    gem 'ruby-debug19', '~> 0.11.6'
    if RUBY_VERSION == '1.9.3'
      if `gem list ruby-debug-base19` =~ /0\.11\.26/
        gem 'ruby-debug-base19', '0.11.26'
      else
        warn "Download and install ruby-debug-base19-0.11.26 from http://rubyforge.org/frs/shownotes.php?release_id=46303"
      end

      if `gem list linecache19` =~ /0\.5\.13/
        gem 'linecache19', '0.5.13'
      else
        warn "Download and install linecache19-0.5.13 from http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem"
      end
    else
      gem 'ruby-debug-base19', '~> 0.11.25'
      gem 'linecache19',       '~> 0.5.12'
    end
  end

  platforms :mri_18, :mri_19 do
    gem "rb-fsevent", "~> 0.4.3.1"
    gem "ruby-prof", "~> 0.10.0"
  end
end
