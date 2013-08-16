require 'active_hash'
require 'active_repository/sql_query_executor'

# Changes made in order to make write support in ActiveHash.

begin
  klass = Module.const_get(ActiveRecord::Rollback)
  unless klass.is_a?(Class)
    raise "Not defined"
  end
rescue
  module ActiveRecord
    class ActiveRecordError < StandardError
    end
    class Rollback < ActiveRecord::ActiveRecordError
    end
  end
end

module ActiveHash
  class Base
    def self.insert(record)
      record_id   = record.id.to_s
      record_hash = record.hash

      remove(record)

      if record_index[record_id].nil? || !self.all.map(&:hash).include?(record_hash)
        insert_record(record)
      end
    end

    def self.remove(record)
      record_id   = record.id.to_s
      record_hash = record.hash

      if self.all.map(&:hash).include?(record_hash)
        record_index.delete(record_id)
        self.all.delete(record)
      end
    end

    def self.where(query)
      if query.is_a?(String)
        return ActiveHash::SQLQueryExecutor.execute(self, query)
      else
        (@records || []).select do |record|
          query.all? { |col, match| record[col] == match }
        end
      end
    end

    def self.validate_unique_id(record)
      raise IdError.new("Duplicate Id found for record #{record.attributes}") if record_index.has_key?(record.id.to_s)
    end

    def update_attribute(key, value)
      self.send("#{key}=", value)
      self.save(:validate => false)
    end

    def readonly?
      false
    end

    def save(*args)
      if self.valid?
        record = self.class.find_by_id(self.id)

        self.class.insert(self) if record.nil? && record != self

        self.id = self.class.last.id if self.id.nil?
        true
      else
        false
      end
    end

    def delete
      record = self.class.find_by_id(self.id)

      self.class.remove(self)

      self.class.find_by_id(self.id).nil?
    end

    def to_param
      id.present? ? id.to_s : nil
    end

    def persisted?
      other = self.class.find_by_id(id)
      other.present?
    end

    def eql?(other)
      (other.instance_of?(self.class) || other.instance_of?(self.class.get_model_class)) && id.present? && (id == other.id) && (!self.respond_to?(:created_at) || (created_at == other.created_at))
    end

    alias == eql?

    private
    def self.insert_record(record)
      @records ||= []
      record.attributes[:id] ||= next_id

      validate_unique_id(record) if dirty
      mark_dirty

      if record.valid?
        add_to_record_index({ record.id.to_s => @records.length })
        @records << record
      end
    end
  end
end
