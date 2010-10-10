rspec-expectations is used to set expectations in executable
examples:

    describe Account do
      it "has a balance of zero when first created" do
        Account.new.balance.should eq(Money.new(0))
      end
    end

## Issues

If you find this documentation incomplete or confusing, please [submit an
issue](http://github.com/rspec/rspec-expectations/issues).
