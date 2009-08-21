clear_maps

@default_runner = 'clear && ruby -Ilib -Ispec'

map_for(:rspec_core) do |m|

  m.watch 'lib', 'spec', 'example_specs'

  m.add_mapping %r%example_specs/(.*)_spec\.rb%, :command => @default_runner  do |match|
    ["example_specs/#{match[1]}_spec.rb"]
  end

  m.add_mapping %r%spec/(.*)_spec\.rb%, :command => @default_runner  do |match|
    ["spec/#{match[1]}_spec.rb"]
  end

  m.add_mapping %r%spec/spec_helper\.rb%, :command => @default_runner  do |match|
    Dir["spec/**/*_spec.rb"]
  end

  m.add_mapping %r%lib/(.*)\.rb%, :command => @default_runner  do |match|
    examples_matching match[1], 'spec'
  end

end
