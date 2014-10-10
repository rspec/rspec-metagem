RSpec.describe "#have_attributes matcher" do

  Person = Struct.new(:name, :age)

  class Person
    def parent(parent_name)
      @parent = parent_name
    end
  end

  let(:wrong_name) { "Wrong Name" }
  let(:wrong_age) { 11 }

  let(:correct_name) { "Correct name" }
  let(:correct_age) { 33 }

  let(:person) { Person.new(correct_name, correct_age) }

  it "is not diffable" do
    expect(have_attributes(:age => correct_age)).to_not be_diffable
  end

  describe "expect(...).to have_attributes(with_one_attribute)" do

    it_behaves_like "an RSpec matcher", :valid_value => Person.new("Correct name", 33), :invalid_value => Person.new("Wrong Name", 11) do
      let(:matcher) { have_attributes(:name => "Correct name") }
    end

    it "passes if target has the provided attributes" do
      expect(person).to have_attributes(:name => correct_name)
    end

    it "fails if target does not have any of the expected attributes" do
      expect {
        expect(person).to have_attributes(:name => wrong_name)
      }.to fail_matching(%r|expected #{object_inspect person} to have attributes #{hash_inspect :name => wrong_name} but had attributes #{hash_inspect :name => correct_name }|)
    end

    it "fails with correct message if object manipulates its data" do
      counter = Class.new do
        def initialize; @count = 1; end
        def count
          @count += 1
        end
      end.new
      expect {
        expect(counter).to have_attributes(:count => 1)
      }.to fail_matching(%r|to have attributes #{hash_inspect :count => 1} but had attributes #{hash_inspect :count => 2 }|)
    end

    it "fails if target does not responds to any of the attributes" do
      expect {
        expect(person).to have_attributes(:color => 'red')
      }.to fail_matching("expected #{object_inspect person} to respond to :color")
    end

    it "fails if target responds to the attribute but requires arguments" do
      expect {
        expect(person).to have_attributes(:parent => 'Billy')
      }.to fail_matching("expected #{object_inspect person} to respond to :parent with 0 arguments")
    end

    describe "expect(...).to have_attributes(key => matcher)" do

      it "passes when the matchers match" do
        expect(person).to have_attributes(:age => (a_value > 30))
      end

      it 'provides a description' do
        description = have_attributes(:age => (a_value > 30)).description
        expect(description).to eq("have attributes {:age => (a value > 30)}")
      end

      it "fails with a clear message when the matcher does not match" do
        expect {
          expect(person).to have_attributes(:age => (a_value < 10))
        }.to fail_matching("expected #{object_inspect person} to have attributes {:age => (a value < 10)}")
      end
    end
  end

  describe "expect(...).to_not have_attributes(with_one_attribute)" do

    it "passes if target does not have any of the expected attributes" do
      expect(person).to_not have_attributes(:age => wrong_age)
    end

    it "fails if target has all of the expected attributes" do
      expect {
        expect(person).to_not have_attributes(:age => correct_age)
      }.to fail_matching(%r|expected #{object_inspect person} not to have attributes #{hash_inspect :age => correct_age}|)
    end

    it "fails if target does not responds to any of the attributes" do
      expect {
        expect(person).to_not have_attributes(:color => 'red')
      }.to fail_matching("expected #{object_inspect person} to respond to :color")
    end

    it "fails if target responds to the attribute but requires arguments" do
      expect {
        expect(person).to_not have_attributes(:parent => 'Billy')
      }.to fail_matching("expected #{object_inspect person} to respond to :parent with 0 arguments")
    end
  end

  describe "expect(...).to have_attributes(with_multiple_attributes)" do

    it_behaves_like "an RSpec matcher", :valid_value => Person.new("Correct name", 33), :invalid_value => Person.new("Wrong Name", 11) do
      let(:matcher) { have_attributes(:name => "Correct name", :age => 33) }
    end

    it "passes if target has the provided attributes" do
      expect(person).to have_attributes(:name => correct_name, :age => correct_age)
    end

    it "fails if target does not have any of the expected attributes" do
      expect {
        expect(person).to have_attributes(:name => correct_name, :age => wrong_age)
      }.to fail_matching(%r|expected #{object_inspect person} to have attributes #{hash_inspect :name => correct_name, :age => wrong_age}|)
    end

    it "fails if target does not responds to any of the attributes" do
      expect {
        expect(person).to have_attributes(:name => correct_name, :color => 'red')
      }.to fail_matching("expected #{object_inspect person} to respond to :color")
    end

    it "fails if target responds to the attribute but requires arguments" do
      expect {
        expect(person).to have_attributes(:name => correct_name, :parent => 'Billy')
      }.to fail_matching("expected #{object_inspect person} to respond to :parent with 0 arguments")
    end
  end

  describe "expect(...).to_not have_attributes(with_multiple_attributes)" do

    it "passes if target has none of the expected attributes" do
      expect(person).to_not have_attributes(:name => wrong_name, :age => wrong_age)
    end

    it "fails if target has any of the expected attributes" do
      expect {
        expect(person).to_not have_attributes(:name => wrong_name, :age => correct_age)
      }.to fail_matching(%r|expected #{object_inspect person} not to have attributes #{hash_inspect :name => wrong_name, :age => correct_age}|)
    end

    it "fails if target has all of the expected attributes" do
      expect {
        expect(person).to_not have_attributes(:name => correct_name, :age => correct_age)
      }.to fail_matching(%r|expected #{object_inspect person} not to have attributes #{hash_inspect :name => correct_name, :age => correct_age}|)
    end

    it "fails if target does not responds to any of the attributes" do
      expect {
        expect(person).to_not have_attributes(:name => correct_name, :color => 'red')
      }.to fail_matching("expected #{object_inspect person} to respond to :color")
    end

    it "fails if target responds to the attribute but requires arguments" do
      expect {
        expect(person).to_not have_attributes(:name => correct_name, :parent => 'Billy')
      }.to fail_matching("expected #{object_inspect person} to respond to :parent with 0 arguments")
    end
  end


  include RSpec::Matchers::Pretty
  # We have to use Hash#inspect in examples that have multi-entry
  # hashes because the #inspect output on 1.8.7 is non-deterministic
  # due to the fact that hashes are not ordered. So we can't simply
  # put a literal string for what we expect because it varies.
  if RUBY_VERSION.to_f == 1.8
    def hash_inspect(hash)
      /\{(#{hash.map { |key,value| "#{key.inspect} => #{value.inspect}.*" }.join "|" }){#{hash.size}}\}/
    end
  else
    def hash_inspect(hash)
      improve_hash_formatting hash.inspect
    end
  end

  include RSpec::Matchers::Composable
  # a helper for failure message assertion
  def object_inspect(object)
    surface_descriptions_in object.inspect
  end

end
