require 'spec_helper'
require 'support/shared_examples'

require 'active_repository'
require 'active_record'
require 'mongoid'

describe ActiveRepository, "Base" do

  before do
    class Country < ActiveRepository::Base
      validates_presence_of :name
    end
  end

  after do
    Object.send :remove_const, :Country
  end

  describe 'postfix' do
    before do
      class CountryPersistence
      end
    end

    context 'when postfix is present' do
      before do
        Country.postfix = "persistence"
        Country.save_in_memory = false
      end

      it 'in persistence_class returns class name and postfix' do
        Country.persistence_class.to_s.should == "CountryPersistence"
      end
    end

    context 'when postfix and persistence_class are present' do
      before do
        Country.postfix = "persistence"
        Country.persistence_class = "CountryModel"
        Country.save_in_memory = false
      end

      it 'in persistence_class returns class name and postfix' do
        Country.persistence_class.to_s.should == "CountryPersistence"
      end
    end

    context 'whe postfix and savi_in_memory are present' do
      before do
        Country.postfix = "persistence"
      end

      it 'in persistence_class returns class name and postfix' do
        Country.persistence_class.to_s.should == "Country"
      end
    end
  end

  context "in_memory", :in_memory do
    before do
      Country.fields :name, :monarch, :language, :created_at, :updated_at
      Country.persistence_class = Country
      Country.save_in_memory = true

      Country.create(:id => 1, :name => "US",     :language => 'English')
      Country.create(:id => 2, :name => "Canada", :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 3, :name => "Mexico", :language => 'Spanish')
      Country.create(:id => 4, :name => "UK",     :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 5, :name => "Brazil")
    end

    it_behaves_like '.constantize'
    it_behaves_like '.serialized_attributes'
    it_behaves_like '.update_attribute'
    it_behaves_like '.update_attributes'
    it_behaves_like '.all'
    it_behaves_like '.where'
    it_behaves_like '.exists?'
    it_behaves_like '.count'
    it_behaves_like '.first'
    it_behaves_like '.last'
    it_behaves_like '.find'
    it_behaves_like '.find_by'
    it_behaves_like '.find_by!'
    it_behaves_like 'custom finders'
    it_behaves_like '#method_missing'
    it_behaves_like '#attributes'
    it_behaves_like 'reader_methods'
    it_behaves_like 'interrogator methods'
    it_behaves_like '#id'
    it_behaves_like '#quoted_id'
    it_behaves_like '#to_param'
    it_behaves_like '#persisted?'
    it_behaves_like '#eql?'
    it_behaves_like '#=='
    it_behaves_like '#hash'
    it_behaves_like '#readonly?'
    it_behaves_like '#cache_key'
    it_behaves_like '#save'
    it_behaves_like '.create'
    it_behaves_like '#valid?'
    it_behaves_like '#new_record?'
    it_behaves_like '.transaction'
    it_behaves_like '.delete_all'
    it_behaves_like '#delete'
    it_behaves_like 'uniqueness'
    it_behaves_like 'uniqueness_with_scope'
  end

  context "active_record", :active_record do
    before do
      Country.fields :name, :monarch, :language, :created_at, :updated_at

      class CountryModel < ActiveRecord::Base
        self.table_name = 'countries'
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table(:countries, :force => true) do |t|
          t.string :name
          t.string :monarch
          t.string :language
          t.datetime :created_at
          t.datetime :updated_at
        end
      end

      Country.persistence_class = CountryModel
      Country.save_in_memory = false

      Country.create(:id => 1, :name => "US",     :language => 'English')
      Country.create(:id => 2, :name => "Canada", :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 3, :name => "Mexico", :language => 'Spanish')
      Country.create(:id => 4, :name => "UK",     :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 5, :name => "Brazil")
    end

    after do
      Object.send :remove_const, :CountryModel
    end

    it_behaves_like '.constantize'
    it_behaves_like '.serialized_attributes'
    it_behaves_like '.update_attribute'
    it_behaves_like '.update_attributes'
    it_behaves_like '.all'
    it_behaves_like '.where'
    it_behaves_like '.exists?'
    it_behaves_like '.count'
    it_behaves_like '.first'
    it_behaves_like '.last'
    it_behaves_like '.find'
    it_behaves_like '.find_by'
    it_behaves_like '.find_by!'
    it_behaves_like 'custom finders'
    it_behaves_like '#method_missing'
    it_behaves_like '#attributes'
    it_behaves_like 'reader_methods'
    it_behaves_like 'interrogator methods'
    it_behaves_like '#id'
    it_behaves_like '#quoted_id'
    it_behaves_like '#to_param'
    it_behaves_like '#persisted?'
    it_behaves_like '#eql?'
    it_behaves_like '#=='
    it_behaves_like '#hash'
    it_behaves_like '#readonly?'
    it_behaves_like '#cache_key'
    it_behaves_like '#save'
    it_behaves_like '.create'
    it_behaves_like '#valid?'
    it_behaves_like '#new_record?'
    it_behaves_like '.transaction'
    it_behaves_like '.delete_all'
    it_behaves_like '#delete'
    it_behaves_like 'uniqueness'
    it_behaves_like 'uniqueness_with_scope'
  end

  context "mongoid", :mongoid do
    before do
      Country.fields :name, :monarch, :language, :created_at, :updated_at

      Mongoid.load!("support/mongoid.yml", :development)

      class CountryModel
        include Mongoid::Document

        store_in collection: "countries"

        field :name
        field :monarch
        field :language
        field :id, type: Integer
        field :updated_at
        field :created_at
      end

      Country.persistence_class = CountryModel
      Country.save_in_memory = false

      Country.delete_all

      Country.create(:id => 1, :name => "US",     :language => 'English')
      Country.create(:id => 2, :name => "Canada", :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 3, :name => "Mexico", :language => 'Spanish')
      Country.create(:id => 4, :name => "UK",     :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 5, :name => "Brazil")
    end

    after do
      Object.send :remove_const, :CountryModel
    end

    it_behaves_like '.constantize'
    it_behaves_like '.serialized_attributes'
    it_behaves_like '.update_attribute'
    it_behaves_like '.update_attributes'
    it_behaves_like '.all'
    it_behaves_like '.where'
    it_behaves_like '.exists?'
    it_behaves_like '.count'
    it_behaves_like '.first'
    it_behaves_like '.last'
    it_behaves_like '.find'
    it_behaves_like '.find_by'
    it_behaves_like '.find_by!'
    it_behaves_like 'custom finders'
    it_behaves_like '#method_missing'
    it_behaves_like '#attributes'
    it_behaves_like 'reader_methods'
    it_behaves_like 'interrogator methods'
    it_behaves_like '#id'
    it_behaves_like '#quoted_id'
    it_behaves_like '#to_param'
    it_behaves_like '#persisted?'
    it_behaves_like '#eql?'
    it_behaves_like '#=='
    it_behaves_like '#hash'
    it_behaves_like '#readonly?'
    it_behaves_like '#cache_key'
    it_behaves_like '#save'
    it_behaves_like '.create'
    it_behaves_like '#valid?'
    it_behaves_like '#new_record?'
    it_behaves_like '.transaction'
    it_behaves_like '.delete_all'
    it_behaves_like '#delete'
    it_behaves_like 'uniqueness'
    it_behaves_like 'uniqueness_with_scope'
  end
end
