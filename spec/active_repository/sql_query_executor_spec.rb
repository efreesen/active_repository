require 'spec_helper'
require 'support/sql_query_shared_examples'

require 'active_repository'
require "active_record"

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
      Country.fields :name, :monarch, :language, :founded_at
      Country.set_model_class(Country)
      Country.set_save_in_memory(true)

      Country.create(:id => 1, :name => "US",     :language => 'English')
      Country.create(:id => 2, :name => "Canada", :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 3, :name => "Mexico", :language => 'Spanish')
      Country.create(:id => 4, :name => "UK",     :language => 'English', :monarch => "The Crown of England")
      Country.create(:id => 5, :name => "Brazil", :founded_at => Time.parse('1500-04-22 13:34:25'))
    end

    describe ".where" do
      it_behaves_like '='
      it_behaves_like '>'
      it_behaves_like '>='
      it_behaves_like '<'
      it_behaves_like '<='
      it_behaves_like 'between'
      it_behaves_like 'is'
    end
  end

  context "active_record" do
    before do
      Country.fields :name, :monarch, :language, :founded_at

      class CountryModel < ActiveRecord::Base
        self.table_name = 'countries'
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table(:countries, :force => true) do |t|
          t.string :name
          t.string :monarch
          t.string :language
          t.datetime :founded_at
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
      Country.create(:id => 5, :name => "Brazil", :founded_at => Time.parse('1500-04-22 13:34:25'))
    end

    after do
      Object.send :remove_const, :CountryModel
    end

    describe ".where" do
      it_behaves_like '='
      it_behaves_like '>'
      it_behaves_like '>='
      it_behaves_like '<'
      it_behaves_like '<='
      it_behaves_like 'between'
      it_behaves_like 'is'
    end
  end
end
