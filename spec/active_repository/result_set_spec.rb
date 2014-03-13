require 'spec_helper'
require 'active_repository'
require 'active_repository/result_set'

describe ActiveRepository::ResultSet, :result_set do
  before do
    class Country < ActiveRepository::Base
      fields :name, :continent
    end
  end

  describe 'initialize' do
    context 'with class only' do
      subject { ActiveRepository::ResultSet.new(Country) }

      it 'must not be nil' do
        expect(subject).not_to be_nil
      end
    end

    context 'with class and attributes' do
      subject { ActiveRepository::ResultSet.new(Country, {a: 'a'}) }

      it 'must not be nil' do
        expect(subject).not_to be_nil
      end
    end
  end

  describe '#count' do
    after do
      Country.delete_all
    end

    context 'without query' do
      it 'returns total records in data store' do
        Country.create
        Country.create
        Country.create
        Country.create

        expect(Country.count).to eq 4
      end
    end

    context 'without query' do
      it 'returns total records in data store' do
        Country.create(name: 'A')
        Country.create
        Country.create(name: 'B')
        Country.create

        expect(Country.where(name: { '$ne' => nil}).count).to eq 2
      end
    end
  end

  describe '#where' do
    subject { ActiveRepository::ResultSet.new(Country) }

    it "returns a ResultSet object" do
      expect(subject.where(name: 'Canada')).to be_a(ActiveRepository::ResultSet)
    end

    it 'creates another ResultSet object' do
      result = subject.where(continent: 'America')

      expect(result).not_to eq subject
    end

    context 'nested ResultSets' do
      it 'returns a new ResultSet' do
        result = subject.where(name: 'Canada').where(continent: 'America')

        expect(result).to be_a(ActiveRepository::ResultSet)
      end

      it 'returns a new ResultSet' do
        result = subject.where(name: 'Canada').where("continent = 'America'")

        expect(result).to be_a(ActiveRepository::ResultSet)
      end
    end
  end

  describe '#and' do
    it 'is an alias for #where' do
      expect(described_class.instance_method(:and)).to eq described_class.instance_method(:where)
    end
  end

  describe '#or' do
    subject { ActiveRepository::ResultSet.new(Country) }

    it "returns a ResultSet object" do
      expect(subject.or(name: 'Canada')).to be_a(ActiveRepository::ResultSet)
    end

    it 'creates another ResultSet object' do
      result = subject.or(continent: 'America')

      expect(result).not_to eq subject
    end

    context 'nested ResultSets' do
      it 'returns a new ResultSet' do
        result = subject.or(name: 'Canada').or(continent: 'America')

        expect(result).to be_a(ActiveRepository::ResultSet)
      end
    end
  end

  describe '#build' do
    subject { ActiveRepository::ResultSet.new(Country) }

    it "returns a Country object" do
      expect(subject.build(name: 'Canada')).to be_a(Country)
    end

    it 'returns a new_record' do
      result = subject.build(continent: 'America')

      expect(result).to be_new_record
    end

    it 'merges attributes' do
      result_set = subject.where(name: 'Canada')
      result = result_set.build(continent: 'America')

      expect(result.attributes).to eq(name: 'Canada', continent: 'America')
    end
  end

  describe '#create' do
    subject { ActiveRepository::ResultSet.new(Country) }

    it "returns a Country object" do
      expect(subject.create(name: 'Canada')).to be_a(Country)
    end

    it 'returns a persisted object' do
      result = subject.create(continent: 'America')

      expect(result).not_to be_new_record
    end

    it 'merges attributes' do
      result_set = subject.where(name: 'Canada')
      result = result_set.create(continent: 'America')

      expect(result.attributes).to eq(name: 'Canada', continent: 'America', id: result.id)
    end
  end

  describe '#all' do
    before do
      Country.delete_all
      Country.create(name: 'Canada', continent: 'America')
      Country.create(name: 'Russia', continent: 'Europe')
      Country.create(name: 'USA', continent: 'America')
      Country.create(name: 'Brazil', continent: 'America')
    end

    subject { ActiveRepository::ResultSet.new(Country) }

    context 'when result_set is not empty' do
      context 'single ResultSet' do
        it 'returns an array of objects' do
          objects = subject.where(continent: 'America').all

          expect(objects.class).to eq Array
        end

        it 'returns a collection of Countries' do
          objects = subject.where(continent: 'America').all

          expect(objects.map(&:class).uniq).to eq [Country]
        end

        it 'returns filtered objects' do
          objects = subject.where(continent: 'America').all

          expect(objects).to eq (Country.all - [Country.find(2)])
        end
      end

      context 'nested ResultSets' do
        it 'returns an array of objects' do
          objects = subject.where(continent: 'America').where(name: 'Canada').all

          expect(objects.class).to eq Array
        end

        it 'returns a collection of Countries' do
          objects = subject.where(continent: 'America').where(name: 'Canada').all

          expect(objects.map(&:class).uniq).to eq [Country]
        end

        it 'returns filtered objects' do
          objects = subject.where(continent: 'America').where(name: 'Canada').all

          expect(objects).to eq ([Country.first])
        end

        it 'returns filtered objects' do
          objects = subject.where(continent: 'America').where("name = 'Canada'").all

          expect(objects).to eq ([Country.first])
        end
      end
    end

    context 'when result_set is empty' do
      it 'returns nil' do
        expect(subject.where('').all).to be_empty
      end
    end
  end

  describe '#first' do
    subject { ActiveRepository::ResultSet.new(Country) }

    context 'when result_set is not empty' do
      it 'returns first object from filtered objects' do
        objects = subject.where(name: 'Russia').or(name: 'USA').first

        expect(objects).to eq Country.find(2)
      end
    end

    context 'when result_set is empty' do
      it 'returns nil' do
        objects = subject.where(name: 'Russia').and(name: 'USA').first

        expect(objects).to be_nil
      end
    end
  end

  describe '#last' do
    subject { ActiveRepository::ResultSet.new(Country) }

    context 'when result_set is not empty' do
      it 'returns first object from filtered objects' do
        objects = subject.where(name: 'Russia').or(name: 'USA').last

        expect(objects).to eq Country.find(3)
      end
    end

    context 'when result_set is empty' do
      it 'returns nil' do
        objects = subject.where(name: 'Russia').and(name: 'USA').first

        expect(objects).to be_nil
      end
    end
  end

  describe '#first_or_initialize' do
    subject { ActiveRepository::ResultSet.new(Country) }

    context 'single query' do
      context 'when result_set is not empty' do
        it 'returns first filtered object' do
          object = subject.where(name: 'Russia').first_or_initialize

          expect(object).to eq Country.find(2)
        end
      end

      context 'when result_set is empty' do
        context 'query is a Hash' do
          it 'returns an object with specified attributes' do
            object = subject.where(name: 'Poland').first_or_initialize

            expect(object.attributes).to eq(name: 'Poland')
          end
        end

        context 'query is not a Hash' do
          it 'returns a new object with specified attributes' do
            object = subject.where("name = 'Poland'").first_or_initialize

            expect(object.attributes).to eq(name: 'Poland')
          end
        end
      end
    end

    context 'nested _query' do
      context 'when result_set is not empty' do
        it 'returns first filtered object' do
          object = subject.where(name: 'Russia').and(continent: 'Europe').first_or_initialize

          expect(object).to eq Country.find(2)
        end
      end

      context 'when result_set is empty' do
        context 'all queries are Hashes' do
          it 'returns a new object with specified attributes' do
            object = subject.where(name: 'Poland').and(continent: 'Europe').first_or_initialize

            expect(object.attributes).to eq(name: 'Poland', continent: 'Europe')
          end
        end

        context 'not all queries are Hashes' do
          it 'returns a new object with all Hashes as attributes' do
            object = subject.where(name: 'Poland').and("continent = 'Europe'").first_or_initialize

            expect(object.attributes).to eq(name: 'Poland', continent: 'Europe')
          end

          it 'returns a new object with all Hashes as attributes' do
            object = subject.where("name = 'Poland'").and("continent = 'Europe'").first_or_initialize

            expect(object.attributes).to eq(name: 'Poland', continent: 'Europe')
          end
        end
      end
    end
  end

  describe '#first_or_create' do
    subject { ActiveRepository::ResultSet.new(Country) }

    before do
      Country.delete_all
      Country.create(name: 'Canada', continent: 'America')
      Country.create(name: 'Russia', continent: 'Europe')
      Country.create(name: 'USA', continent: 'America')
      Country.create(name: 'Brazil', continent: 'America')
    end

    context 'single query' do
      context 'when result_set is not empty' do
        it 'returns first filtered object' do
          object = subject.where(name: 'Russia').first_or_create

          expect(object).to eq Country.find(2)
        end
      end

      context 'when result_set is empty' do
        context 'query is a Hash' do
          it 'returns an object with id not nil' do
            object = subject.where(name: 'Poland').first_or_create

            expect(object.id).to eq Country.last.id
          end

          it 'returns an object with specified attributes' do
            object = subject.where(name: 'Poland').first_or_create

            expect(object.attributes).to eq(id: 5, name: 'Poland')
          end
        end

        context 'query is not a Hash' do
          it 'returns a new object with specified attributes' do
            object = subject.where("name = 'Poland'").first_or_create

            expect(object.attributes).to eq(name: 'Poland', id: 5)
          end
        end
      end
    end

    context 'nested _query' do
      context 'when result_set is not empty' do
        it 'returns first filtered object' do
          object = subject.where(name: 'Russia').and(continent: 'Europe').first_or_create

          expect(object).to eq Country.find(2)
        end
      end

      context 'when result_set is empty' do
        context 'all queries are Hashes' do
          it 'returns a new object with specified attributes' do
            object = subject.where(name: 'Poland').and(continent: 'Europe').first_or_create

            expect(object.attributes).to eq(id: 5, name: 'Poland', continent: 'Europe')
          end
        end

        context 'not all queries are Hashes' do
          it 'returns a new object with all Hashes as attributes' do
            object = subject.where(name: 'Poland').and("continent = 'Europe'").first_or_create

            expect(object.attributes).to eq(id: 5, name: 'Poland', continent: 'Europe')
          end

          it 'returns a new object with all Hashes as attributes' do
            object = subject.where("name = 'Poland'").and("continent = 'Europe'").first_or_create

            expect(object.attributes).to eq(:name=>"Poland", :continent=>"Europe", :id=>5)
          end
        end
      end
    end
  end
end
