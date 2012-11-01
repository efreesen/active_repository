require 'spec_helper'
require 'support/shared_examples'

require 'active_repository'
require "active_record"
require "mongoid"

describe ActiveRepository, "Base" do

  before do
    class Country < ActiveRepository::Base
    end
  end

  after do
    Object.send :remove_const, :Country
  end

  context "in_memory" do
    before do
      Country.fields :name, :monarch, :language
      Country.set_model_class(Country)
      Country.set_save_in_memory(true)

      Country.create(:id => 1, :name => "US",     :language => 'English')
      Country.create(:id => 2, :name => "Canada", :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 3, :name => "Mexico", :language => 'Spanish')
      Country.create(:id => 4, :name => "UK",     :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 5, :name => "Brazil")
    end

    it_behaves_like '.update_attributes'
    it_behaves_like '.all'
    it_behaves_like '.where'
    it_behaves_like '.exists?'
    it_behaves_like '.count'
    it_behaves_like '.first'
    it_behaves_like '.last'
    it_behaves_like '.find'
    it_behaves_like '.find_by_id'
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
  end

  context "active_record" do
    before do
      Country.fields :name, :monarch, :language

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

      Country.set_model_class(CountryModel)
      Country.set_save_in_memory(false)

      Country.create(:id => 1, :name => "US",     :language => 'English')
      Country.create(:id => 2, :name => "Canada", :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 3, :name => "Mexico", :language => 'Spanish')
      Country.create(:id => 4, :name => "UK",     :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 5, :name => "Brazil")
    end

    after do
      Object.send :remove_const, :CountryModel
    end

    it_behaves_like '.update_attributes'
    it_behaves_like '.all'
    it_behaves_like '.where'
    it_behaves_like '.exists?'
    it_behaves_like '.count'
    it_behaves_like '.first'
    it_behaves_like '.last'
    it_behaves_like '.find'
    it_behaves_like '.find_by_id'
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
  end
end
