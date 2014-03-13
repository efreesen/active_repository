require 'set'

shared_examples ".serialized_attributes" do
  it "returns class name" do
    Country.serialized_attributes.should == ["name", "monarch", "language", "created_at", "updated_at"]
  end
end

shared_examples ".constantize" do
  it "returns class name" do
    Country.constantize.should == Country
  end
end

shared_examples ".update_attribute" do
  it "updates records" do
    id = Country.first.id
    country = Country.find(id)
    country.update_attribute(:name, "Italy")

    Country.first.name.should == "Italy"
  end

  it "updates records whit string keys" do
    id = Country.first.id
    country = Country.find(id)
    country.update_attribute('name', "Germany")

    Country.first.name.should == "Germany"
  end
end

shared_examples ".update_attributes" do
  it "updates records" do
    id = Country.first.id
    country = Country.find(id)
    country.update_attributes(:name => "Italy")

    Country.first.name.should == "Italy"
  end

  it "updates records whit string keys" do
    id = Country.first.id
    country = Country.find(id)
    country.update_attributes('name' => "Germany")

    Country.first.name.should == "Germany"
  end
end

shared_examples ".all" do
  it "returns an empty array if data is nil" do
    Country.delete_all
    Country.all.should be_empty
  end

  it "returns all data as repository objects" do
    Country.all.all? { |country| country.should be_kind_of(Country) }
  end

  it "populates the data correctly" do
    records = Country.all
    records.should include(Country.first)
    records.should include(Country.last)
    records.size.should == 5
  end
end

shared_examples ".where" do
  it "raises ArgumentError if no conditions are provided" do
    lambda{
      Country.where
    }.should raise_error(ArgumentError)
  end

  it "returns all data as inflated objects" do
    expect(Country.where(:language => 'English', :name => 'US')).to be_a ActiveRepository::ResultSet
  end

  it "populates the data correctly" do
    first_id = Country.first.id
    last_id  = Country.all[3].id

    results = Country.where(:language => 'English').all
    results.first.id.should == first_id
    results.first.name.should == "US"
    results.last.id.should == last_id
    results.last.name.should == "UK"
  end

  it "filters the records from an AR-like conditions hash" do
    first_id = Country.first.id

    results = Country.where(:name => 'US').all
    results.count.should == 1
    results.first.id.should == first_id
    results.first.name.should == 'US'
  end
end

shared_examples ".exists?" do
  it "checks if a record exists" do
    id = Country.last.id

    Country.delete_all
    Country.exists?(id).should be_false

    country = Country.create(:name => "France")
    id = country.id

    Country.exists?(id).should be_true
  end
end

shared_examples ".count" do
  it "returns the number of elements in the array" do
    Country.count.should == 5
  end
end

shared_examples ".first" do
  it "returns the first object" do
    first = Country.first

    first.should == Country.find(first.id)
  end
end

shared_examples ".last" do
  it "returns the last object" do
    last = Country.last

    last.should == Country.find(last.id)
  end
end

shared_examples ".find" do
  context "with an id" do
    it "finds the record with the specified id" do
      second_id = Country.all[1].id
      Country.find(second_id).id.should == second_id
    end

    it "finds the record with the specified id as a string" do
      second_id = Country.all[1].id

      Country.find(second_id.to_s).id.should == second_id
    end

    it "raises ActiveHash::RecordNotFound when id not found" do
      proc do
        Country.find(0)
      end.should raise_error(ActiveHash::RecordNotFound, /Couldn't find Country with ID=0/)
    end
  end

  context "with an array of ids" do
    it "returns all matching ids" do
      countries = Country.all
      ids = [countries[0].id, countries[2].id]
      Country.find(ids).should == [Country.find(ids.first), Country.find(ids.last)]
    end

    it "raises ActiveHash::RecordNotFound when id not found" do
      proc do
        Country.find([0, 3])
      end.should raise_error(ActiveHash::RecordNotFound, "Couldn't find all Country objects with IDs (0, 3)")
    end
  end
end

shared_examples ".find_by" do
  context "with an id" do
    it "finds the record with the specified id" do
      id = Country.all[1].id
      Country.find_by(id: id).id.should == id
    end

    it "finds the record with the specified id as a string" do
      id = Country.all[1].id
      Country.find_by(id: id.to_s).id.should == id
    end
  end

  context "with nil" do
    it "returns nil" do
      Country.find_by(id: nil).should be_nil
    end
  end

  context "with an id not present" do
    it "returns nil" do
      Country.find_by(id: 4567).should be_nil
    end
  end

  context 'with an existing name' do
    it "returns found element" do
      Country.find_by(name: 'Canada').should == Country.all[1]
    end
  end

  context 'with a not existing name' do
    it "returns found element" do
      Country.find_by(name: 'China').should be_nil
    end
  end
end

shared_examples ".find_by!" do
  context "with an id" do
    it "finds the record with the specified id" do
      id = Country.all[1].id
      Country.find_by!(id: id).id.should == id
    end

    it "finds the record with the specified id as a string" do
      id = Country.all[1].id
      Country.find_by!(id: id.to_s).id.should == id
    end
  end

  context "with nil" do
    it "returns nil" do
      lambda {
        Country.find_by!(id: nil)
      }.should raise_error(ActiveHash::RecordNotFound)
    end
  end

  context "with an id not present" do
    it "returns nil" do
      lambda {
        Country.find_by!(id: 4567)
      }.should raise_error(ActiveHash::RecordNotFound)
    end
  end

  context 'with an existing name' do
    it "returns found element" do
      Country.find_by!(name: 'Canada').should == Country.all[1]
    end
  end

  context 'with a not existing name' do
    it "returns found element" do
      lambda {
        Country.find_by!(name: 'China')
      }.should raise_error(ActiveHash::RecordNotFound)
    end
  end
end

shared_examples "custom finders" do
  describe "find_by_<field_name>" do
    describe "with a match" do
      context "for a non-nil argument" do
        it "returns the first matching record" do
          id = Country.first.id
          Country.where(:name => "US").first.id.should == id
        end
      end

      context "for a nil argument" do
        it "returns the first matching record" do
          id = Country.all[2].id
          Country.where(:language => 'Spanish').first.id.should == id
        end
      end
    end

    describe "without a match" do
      context "for a non-nil argument" do
        it "returns nil" do
          Country.find_by_name("Argentina").should be_nil
        end
      end

      context "for a nil argument" do
        it "returns nil" do
          Country.find_by_name(nil).should be_nil
        end
      end
    end
  end

  describe "find_all_by_<field_name>" do
    describe "with matches" do
      it "returns all matching records" do
        countries = Country.find_all_by_language("English")
        countries.length.should == 3
        countries.first.name.should == "US"
        countries.last.name.should == "UK"
      end
    end

    describe "without matches" do
      it "returns an empty array" do
        Country.find_all_by_name("Argentina").should be_empty
      end
    end
  end

  describe "find_by_<field_one>_and_<field_two>" do
    describe "with a match" do
      it "returns the first matching record" do
        id = Country.all[1].id
        Country.find_by_name_and_language("Canada", "English").id.should == id
        Country.find_by_language_and_name("English", "Canada").id.should == id
      end
    end

    describe "with a match based on to_s" do
      it "returns the first matching record" do
        id = Country.all[1].id
        Country.find_by_name_and_id("Canada", id.to_s).id.should == id
      end
    end

    describe "without a match" do
      it "returns nil" do
        Country.find_by_name_and_monarch("Mexico", "The Crown of England").should be_nil
      end
    end

    describe "for fields the class doesn't have" do
      it "raises a NoMethodError" do
        lambda {
          Country.find_by_name_and_shoe_size("US", 10)
        }.should raise_error(NoMethodError, "undefined method `find_by_name_and_shoe_size' for Country:Class")
      end
    end
  end

  describe "find_all_by_<field_one>_and_<field_two>" do
    describe "with matches" do
      it "returns all matching records" do
        countries = Country.find_all_by_language_and_monarch("English", "The Crown of England")
        countries.length.should == 2
        countries.first.name.should == "Canada"
        countries.last.name.should == "UK"
      end
    end

    describe "without matches" do
      it "returns an empty array" do
        Country.find_all_by_monarch_and_language("Shaka Zulu", "Zulu").should be_empty
      end
    end
  end
end

shared_examples "#method_missing" do
  it "doesn't blow up if you call a missing dynamic finder when fields haven't been set" do
    proc do
      Country.find_by_size("Foo")
    end.should raise_error(NoMethodError, "undefined method `find_by_size' for Country:Class")
  end
end

shared_examples "#attributes" do
  before do
    Country.field :foo
  end

  it "returns the hash passed in the initializer" do
    country = Country.new(:foo => :bar)
    country.attributes.should == {:foo => :bar}
  end

  it "symbolizes keys" do
    country = Country.new("foo" => :bar)
    country.attributes.should == {:foo => :bar}
  end

  it "is works with #[]" do
    country = Country.new(:foo => :bar)
    country.foo.should == :bar
  end

  it "is works with #[]=" do
    country = Country.new
    country.foo = :bar
    country.foo.should == :bar
  end
end

shared_examples "reader_methods" do
  context "for regular fields" do
    before do
      Country.fields :name, :iso_name
    end

    it "returns the given attribute when present" do
      country = Country.new(:name => "Spain")
      country.name.should == "Spain"
    end

    it "returns nil when not present" do
      country = Country.new
      country.name.should be_nil
    end
  end
end

shared_examples "interrogator methods" do
  before do
    Country.fields :name, :iso_name
  end

  it "returns true if the given attribute is non-blank" do
    country = Country.new(:name => "Spain")
    country.should be_name
  end

  it "returns false if the given attribute is blank" do
    country = Country.new(:name => " ")
    country.name?.should == false
  end

  it "returns false if the given attribute was not passed" do
    country = Country.new
    country.should_not be_name
  end
end

shared_examples "#id" do
  context "when not passed an id" do
    it "returns nil" do
      country = Country.new
      country.id.should be_nil
    end
  end
end

shared_examples "#quoted_id" do
  it "should return id" do
    Country.new(:id => 2).quoted_id.should == 2
  end
end

shared_examples "#to_param" do
  it "should return id as a string" do
    country = Country.create(name: 'Brazil')
    country.to_param.should == country.id.to_s
  end
end

shared_examples "#persisted?" do
  it "should return true if the object has been saved" do
    Country.delete_all
    Country.create(:id => 2, name: 'Brazil').should be_persisted
  end

  it "should return false if the object has not been saved" do
    Country.new(:id => 12).should_not be_persisted
  end
end

shared_examples "#eql?" do
  before do
    class Region < ActiveRepository::Base
    end
  end

  it "should return true with the same class and id" do
    Country.new(:id => 23).eql?(Country.new(:id => 23)).should be_true
  end

  it "should return false with the same class and different ids" do
    Country.new(:id => 24).eql?(Country.new(:id => 23)).should be_false
  end

  it "should return false with the different classes and the same id" do
    Country.new(:id => 23).eql?(Region.new(:id => 23)).should be_false
  end

  it "returns false when id is nil" do
    Country.new.eql?(Country.new).should be_false
  end
end

shared_examples "#==" do
  before do
    class Region < ActiveRepository::Base
    end
  end

  it "should return true with the same class and id" do
    Country.new(:id => 23).should == Country.new(:id => 23)
  end

  it "should return false with the same class and different ids" do
    Country.new(:id => 24).should_not == Country.new(:id => 23)
  end

  it "should return false with the different classes and the same id" do
    Country.new(:id => 23).should_not == Region.new(:id => 23)
  end

  it "returns false when id is nil" do
    Country.new.should_not == Country.new
  end
end

shared_examples "#hash" do
  it "returns id for hash" do
    Country.new(:id => 45).hash.should == 45.hash
    Country.new.hash.should == nil.hash
  end

  it "is hashable" do
    {Country.new(:id => 4) => "bar"}.should == {Country.new(:id => 4) => "bar"}
    {Country.new(:id => 3) => "bar"}.should_not == {Country.new(:id => 4) => "bar"}
  end
end

shared_examples "#readonly?" do
  it "returns true" do
    Country.new.should_not be_readonly
  end

  it "updates a record" do
    id = Country.first.id

    country = Country.find(id)

    country.name = "Germany"

    country.save.should be_true

    Country.all.size.should == 5
    country.should be_valid
    country.name.should == "Germany"
    country.id.should == id
  end
end

shared_examples "#cache_key" do
  before do
    Country.delete_all
  end

  it 'should use the record\'s updated_at if present' do
    country = Country.create(:name => "foo")

    country.reload

    date_string = country.updated_at.nil? ? "" : "-#{country.updated_at.to_s(:number)}"
    id          = country.id

    Country.first.cache_key.should == "countries/#{id}#{date_string}"
  end

  it 'should use "new" instead of the id for a new record' do
    Country.new(:id => 1).cache_key.should == 'countries/new'
  end
end

shared_examples "#save" do
  before do
    Country.field :name
    Country.delete_all
  end

  it "does not add object to the collection if it is not valid" do
    country = Country.new :monarch => "King", :language => "bar"
    country.save.should be_false
    Country.count.should == 0
  end

  it "adds the new object to the data collection" do
    Country.all.should be_empty
    country = Country.new :name => "foo", :monarch => "King", :language => "bar"
    country.save.should be_true
    country.reload

    countries_attributes =  Country.first.attributes
    countries_attributes.delete(:created_at)
    countries_attributes.delete(:updated_at)

    expected_attributes = country.attributes
    expected_attributes.delete(:created_at)
    expected_attributes.delete(:updated_at)

    countries_attributes.should == expected_attributes
  end
end

shared_examples ".create" do
  before do
    Country.field :name
    Country.delete_all
  end

  it "works with no args" do
    Country.all.should be_empty
    country = Country.create(name: 'Brazil')

    country.id.should == Country.last.id
  end

  it "adds the new object to the data collection" do
    Country.all.should be_empty
    country = Country.create :name => "foo"
    country.id.should == Country.last.id
    country.name.should == "foo"

    countries_attributes = Country.all.map(&:attributes)
    expected_attributes  = [country].map(&:attributes)

    countries_attributes.each do |a|
      a.delete(:created_at)
      a.delete(:updated_at)
    end

    expected_attributes.each do |a|
      a.delete(:created_at)
      a.delete(:updated_at)
    end

    countries_attributes.should == expected_attributes
  end

  it "adds an auto-incrementing id if the id is nil and not MongoMapper" do
    country1 = Country.new :name => "foo"
    country1.save

    country2 = Country.new :name => "bar"
    country2.save
    country2.id.should == ((["BSON::ObjectId", "Moped::BSON::ObjectId"].include?(country1.id.class.name)) ? country2.id : country1.id + 1)
  end

  it "adds the new object to the data collection" do
    Country.all.should be_empty
    country = Country.create :name => "foo"
    country.id.should == Country.last.id
    country.name.should == "foo"

    countries_attributes = Country.all.map(&:attributes)
    expected_attributes  = [country].map(&:attributes)

    countries_attributes.each do |a|
      a.delete(:created_at)
      a.delete(:updated_at)
    end

    expected_attributes.each do |a|
      a.delete(:created_at)
      a.delete(:updated_at)
    end

    countries_attributes.should == expected_attributes
  end

  it "updates count" do
    proc {
      Country.create :name => "Russia"
    }.should change { Country.count }
  end
end

shared_examples "#valid?" do
  it "should return true" do
    Country.new(name: 'Brazil').should be_valid
  end
end

shared_examples "#new_record?" do
  before do
    Country.field :name
    Country.delete_all
    Country.create(:id => 1, :name => "foo")
  end

  it "returns true when the object is not part of the collection" do
    Country.new(:id => 2).should be_new_record
  end
end

shared_examples ".transaction" do
  it "execute the block given to it" do
    foo = Object.new
    foo.should_receive(:bar)
    Country.transaction do
      foo.bar
    end
  end

  it "swallows ActiveRecord::Rollback errors" do
    proc do
      Country.transaction do
        raise ActiveRecord::Rollback
      end
    end.should_not raise_error
  end

  it "passes other errors through" do
    proc do
      Country.transaction do
        raise "hell"
      end
    end.should raise_error("hell")
  end
end

shared_examples "#delete" do
  before do
    Country.delete_all
  end

  it "removes a record" do
    country = Country.create(name: 'Brazil')

    Country.count.should == 1

    country.delete

    Country.count.should == 0
  end
end

shared_examples ".delete_all" do
  before do
    Country.delete_all
  end

  it "clears out all record" do
    country1 = Country.create(name: 'Brazil')
    country2 = Country.create(name: 'Brazil')

    countries_attributes = Country.all.map(&:attributes)
    expected_attributes  = [country1, country2].map(&:attributes)

    countries_attributes.each do |a|
      a.delete(:created_at)
      a.delete(:updated_at)
    end

    expected_attributes.each do |a|
      a.delete(:created_at)
      a.delete(:updated_at)
    end

    countries_attributes.should == expected_attributes
    Country.delete_all
    Country.all.should be_empty
  end
end

shared_examples "uniqueness" do
  before do
    Country.delete_all
    Country.validates_uniqueness_of :name
  end

  it "does not accept duplicated ids" do
    country1 = Country.create(name: 'Brazil')
    country2 = Country.create(name: 'Brazil')

    country1.should be_valid
    country2.should_not be_valid
    Country.count.should == 1
    Country.all.should == [country1]
  end
end