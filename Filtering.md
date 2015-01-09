RSpec supports the filtering of examples and groups by matching tags declared on
the command line or options files, or filters declared via
`RSpec.configure`, with hash key/values submitted within example group
and/or example declarations. For example, given this declaration:

    describe Thing, :awesome => true do
      it "does something" do
        # ...
      end
    end

That group (or any other with `:awesome => true`) would be filtered in
with any of the following commands:

    rspec --tag awesome:true
    rspec --tag awesome
    rspec -t awesome:true
    rspec -t awesome

Prefixing the tag names with `~` negates the tags, thus excluding this
group with any of:

    rspec --tag ~awesome:true
    rspec --tag ~awesome
    rspec -t ~awesome:true
    rspec -t ~awesome

## Options files and command line overrides

Tag declarations can be stored in `.rspec`, `~/.rspec`, or a custom
options file. This is useful for storing defaults. For example, let's
say you've got some slow specs that you want to suppress most of the
time. You can tag them like this:

    describe Something, :slow => true do

And then store this in `.rspec`:

    --tag ~slow:true

Now when you run `rspec`, that group will be excluded.

## Overriding

Of course, you probably want to run them sometimes, so you can override
this tag on the command line like this:

    rspec --tag slow:true

## RSpec.configure

You can also store default tags with `RSpec.configure`. We use `tag` on
the command line (and in options files like `.rspec`), but for historical
reasons we use the term `filter` in `RSpec.configure:

    RSpec.configure do |c|
      c.filter_run_including :foo => :bar
      c.filter_run_excluding :foo => :bar
    end

These declarations can also be overridden from the command line.
