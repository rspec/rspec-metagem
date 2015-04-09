# Deliberately named _specs.rb to avoid being loaded except when specified

RSpec.configure do |c|
  c.register_ordering(:global, &:shuffle)
end

10.times do |i|
  RSpec.describe "Group #{i}" do
    it("passes") {      }
    it("fails")  { fail }
  end
end
