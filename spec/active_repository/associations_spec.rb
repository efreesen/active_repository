require 'spec_helper'
require 'active_repository'
require 'active_record'
require 'mongoid'

describe ActiveRepository::Base, "associations" do
  before do
    class Country < ActiveRecord::Base
      establish_connection :adapter => "sqlite3", :database => ":memory:"
      connection.create_table(:countries, :force => true) {}
    end

    class CountryRepository < ActiveRepository::Base
      self.persistence_class = Country
      self.save_in_memory = false
    end

    class Mountain < ActiveRecord::Base
      establish_connection :adapter => "sqlite3", :database => ":memory:"
      connection.create_table(:mountains, :force => true) do |t|
        t.integer :country_id
      end
    end

    class President < ActiveRecord::Base
      establish_connection :adapter => "sqlite3", :database => ":memory:"
      connection.create_table(:presidents, :force => true) do |t|
        t.integer :country_id
      end
    end

    class School < ActiveRecord::Base
      establish_connection :adapter => "sqlite3", :database => ":memory:"
      connection.create_table(:schools, :force => true) do |t|
        t.integer :city_id
      end
    end

    class City < ActiveRepository::Base
      fields :name
    end

    class Author < ActiveRepository::Base
    end

    class Book < ActiveRecord::Base
      establish_connection :adapter => "sqlite3", :database => ":memory:"
      connection.create_table(:books, :force => true) do |t|
        t.integer :author_id
        t.boolean :published
      end

      if Object.const_defined?(:ActiveModel)
        scope :published, -> { where(published: true) }
      else
        named_scope :published, -> { where(:published => true) }
      end
    end
  end

  after do
    Object.send :remove_const, :City
    Object.send :remove_const, :Author
    Object.send :remove_const, :Country
    Object.send :remove_const, :CountryRepository
    Object.send :remove_const, :Mountain
    Object.send :remove_const, :President
    Object.send :remove_const, :School
    Object.send :remove_const, :Book
  end

  describe "#has_many" do

    context "with ActiveRecord children" do
      before do
        @included_book_1 = Book.create! :author_id => 1, :published => true
        @included_book_2 = Book.create! :author_id => 1, :published => false
        @excluded_book = Book.create! :author_id => 2, :published => true
      end

      it "find the correct records" do
        Author.has_many :books
        author = Author.create :id => 1
        author.books.should == [@included_book_1, @included_book_2]
      end

      it "return a scope so that we can apply further scopes" do
        Author.has_many :books
        author = Author.create :id => 1
        author.books.published.should == [@included_book_1]
      end
    end

    context "with ActiveRepository children" do
      before do
        Author.field :city_id
        @included_author_1 = Author.create :city_id => 1
        @included_author_2 = Author.create :city_id => 1
        @excluded_author = Author.create :city_id => 2
      end

      it "find the correct records" do
        City.has_many :authors
        city = City.create :id => 1
        city.authors.all.should == [@included_author_1, @included_author_2]
      end

      it "uses the correct class name when passed" do
        City.has_many :writers, :class_name => "Author"
        city = City.create :id => 1
        city.writers.all.should == [@included_author_1, @included_author_2]
      end
    end

    context "with ActiveRecord children but different naming scheme requiring foreign_key option" do
      it "honors foreign_key option to properly fetch child records from has_many" do
        CountryRepository.has_many :mountains, :foreign_key => "country_id"
        country = Country.create :id => 1
        mountain_1 = Mountain.create :country_id => 1, :id => 1
        expect(CountryRepository.first.mountains).to eq([mountain_1])
      end

      it "honors foreign_key option to properly fetch child record from has_one" do
        CountryRepository.has_one :president, :foreign_key => "country_id"
        country = Country.create :id => 1
        president_1 = President.create :country_id => 1, :id => 1
        expect(CountryRepository.first.president).to eq(president_1)
      end
    end

  end

  describe "#belongs_to" do
    context "with an ActiveRecord parent" do
      it "find the correct records" do
        City.belongs_to :country
        country = Country.create
        city = City.create :country_id => country.id
        city.country.should == country
      end

      it "returns nil when the record does not exist" do
        City.belongs_to :country
        city = City.create :country_id => 123
        city.country.should be_nil
      end
    end

    context "with an ActiveRepository parent" do
      it "find the correct records" do
        Author.belongs_to :city
        city = City.create
        author = Author.create :city_id => city.id
        author.city.should == city
      end

      it "returns nil when the record does not exist" do
        Author.belongs_to :city
        author = Author.create :city_id => 123
        author.city.should be_nil
      end
    end

    describe "#parent=" do
      before do
        Author.belongs_to :city
        @city = City.create :id => 1
      end

      it "sets the underlying id of the parent" do
        author = Author.new
        author.city = @city
        author.city_id.should == @city.id
      end

      it "works from hash assignment" do
        author = Author.new :city => @city
        author.city_id.should == @city.id
        author.city.should == @city
      end

      it "works with nil" do
        author = Author.new :city => @city
        author.city_id.should == @city.id
        author.city.should == @city

        author.city = nil
        author.city_id.should be_nil
        author.city.should be_nil
      end
    end

    describe "with a different foreign key" do
      before do
        Author.belongs_to :residence, :class_name => "City", :foreign_key => "city_id"
        @city = City.create :id => 1
      end

      it "works" do
        author = Author.new
        author.residence = @city
        author.city_id.should == @city.id
      end
    end

    describe '#create_association' do
      before do
        Author.belongs_to :city
      end

      it "creates a city related to author" do
        author = Author.new
        city = author.create_city(name: 'Metropolis')

        author.city.name.should == 'Metropolis'
        author.city_id.should == city.id
        author.city.should == city
      end
    end
  end

  describe "#has_one" do
    context "with ActiveRecord children" do
      before do
        Author.has_one :book
      end

      it "find the correct records" do
        book = Book.create! :author_id => 1, :published => true
        author = Author.create :id => 1
        author.book.should == book
      end

      it "returns nil when there is no record" do
        author = Author.create :id => 1
        author.book.should be_nil
      end
    end

    context "with ActiveRepository children" do
      before do
        City.has_one :author
        Author.field :city_id
      end

      it "find the correct records" do
        city = City.create :id => 1
        author = Author.create :city_id => 1
        city.author.should == author
      end

      it "returns nil when there are no records" do
        city = City.create :id => 1
        city.author.should be_nil
      end
    end

    context "with class_name and foreign_key explicitly specified" do
      before do
        City.has_one :second_author, class_name: "Author", foreign_key: :main_city_id
        Author.field :main_city_id
      end

      it "returns the correct child" do
        city = City.create id: 1
        author = Author.create main_city_id: 1
        expect(city.second_author).to eq(author)
      end

      it "sets the child correctly" do
        city = City.create
        author = Author.create
        city.second_author = author
        expect(city.second_author).to eq(author)
        expect(author.main_city_id).to eq(city.id)
      end
    end

    describe '#create_association' do
      before do
        City.has_one :author
        Author.field :city_id
        Author.field :name
      end

      it "creates a city related to author" do
        city = City.create
        author = city.create_author(name: 'Clark Kent')

        city.author.name.should == 'Clark Kent'
        author.city_id.should == city.id
        city.author.should == author
      end

      it "replaces existing relation using #create method" do
        city = City.create
        old_author = city.create_author(name: 'Clark Kent')
        author = city.create_author(name: 'Bruce Wayne')

        Author.where(city_id: city.id).count.should == 1
        city.author.name.should == 'Bruce Wayne'
        author.city_id.should == city.id
        city.author.should == author
      end
    end
  end

  describe "#marked_for_destruction?" do
    it "should return false" do
      City.new.marked_for_destruction?.should == false
    end
  end

  describe "Multiple ORM" do
    before do
      Object.send :remove_const, :City
      Object.send :remove_const, :Country

      class Country < ActiveRepository::Base
        has_many :states
      end

      class StateModel < ActiveRecord::Base
        self.table_name = 'states'
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table(:states) do |t|
          t.integer :country_id
        end
      end

      class State < ActiveRepository::Base
        State.persistence_class = StateModel
        State.save_in_memory = false
        belongs_to :country
        has_many :cities

        fields :country_id, :city_id
      end

      Mongoid.load!("support/mongoid.yml", :development)

      class CityModel
        include Mongoid::Document
        store_in collection: "countries"
        field :state_id
      end

      class City < ActiveRepository::Base
        City.persistence_class = CityModel
        City.save_in_memory = false
        belongs_to :state
        has_many   :regions
      end
    end

    after do
      City.delete_all
      State.delete_all

      Object.send :remove_const, :CityModel
      Object.send :remove_const, :State
      Object.send :remove_const, :StateModel
    end

    context ActiveRepository do
      it "relates with ActiveRecord models" do
        country = Country.create
        state   = State.create(:country_id => country.id)

        country.states.all.should == [state]
      end
    end

    context ActiveRecord do
      it "relates with ActiveRepository objects" do
        country = Country.create
        state   = State.create(:country_id => country.id)

        state.country.should == country
      end

      it "relates with Mongoid models" do
        state = State.create
        city  = City.create(:state_id => state.id)


        state.cities.all.should == [city]
      end
    end

    context Mongoid do
      it "relates with ActiveRecord models" do
        state = State.create
        city  = City.create(:state_id => state.id)

        city.state.should == state
      end
    end
  end

end
