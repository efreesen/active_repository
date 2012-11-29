require 'active_repository/associations'
require 'active_repository/uniqueness'
require 'active_repository/write_support'
require 'active_repository/sql_query_executor'
require 'active_repository/finders'
require 'active_repository/writers'

module ActiveRepository

  class Base < ActiveHash::Base
    extend ActiveModel::Callbacks
    extend ActiveRepository::Finders
    extend ActiveRepository::Writers
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveRepository::Associations
    include ActiveRepository::Writers::InstanceMethods

    class_attribute :model_class, :save_in_memory, :instance_writer => false

    before_validation :set_timestamps

    fields :created_at, :updated_at

    def self.all
      self == get_model_class ? super : get_model_class.all.map { |object| serialize!(object.attributes) }
    end

    def self.constantize
      self.to_s.constantize
    end

    def self.delete_all
      self == get_model_class ? super : get_model_class.delete_all
    end

    def self.exists?(id)
      if self == get_model_class
        !find_by_id(id).nil?
      else
        if mongoid?
          find_by_id(id).present?
        else
          get_model_class.exists?(id)
        end
      end
    end

    def self.get_model_class
      return self if self.save_in_memory.nil?
      save_in_memory? ? self : self.model_class
    end

    def self.serialize!(other)
      case other.class.to_s
      when "Hash" then self.new.serialize!(other)
      when "Array" then other.map { |o| serialize!(o.attributes) }
      when "Moped::BSON::Document" then self.new.serialize!(other)
      else self.new.serialize!(other.attributes)
      end
    end

    def self.serialized_attributes
      field_names.map &:to_s
    end

    def self.set_model_class(value)
      self.model_class = value if model_class.nil?

      field_names.each do |field_name|
        define_custom_find_by_field(field_name)
        define_custom_find_all_by_field(field_name)
      end
    end

    def self.set_save_in_memory(value)
      self.save_in_memory = value if save_in_memory.nil?
    end

    def self.where(*args)
      raise ArgumentError.new("wrong number of arguments (0 for 1)") if args.empty?
      if self == get_model_class
        query = ActiveHash::SQLQueryExecutor.args_to_query(args)
        super(query)
      else
        objects = []
        args = args.first.is_a?(Hash) ? args.first : args
        get_model_class.where(args).each do |object|
          objects << self.serialize!(object.attributes)
        end

        objects
      end
    end

    def persist
      if self.valid?
        save_in_memory? ? save : self.convert
      end
    end

    def reload
      serialize! self.class.get_model_class.find(self.id).attributes
    end

    def save_in_memory?
      self.save_in_memory.nil? ? true : save_in_memory
    end

    def serialize!(attributes)
      unless attributes.nil?
        self.attributes = attributes
      end

      self
    end

    protected
      def convert(attribute="id")
        klass = self.class.get_model_class
        object = klass.where(attribute.to_sym => self.send(attribute)).first
        
        object ||= self.class.get_model_class.new

        attributes = self.attributes

        attributes.delete(:id)

        object.attributes = attributes

        object.save

        self.id = object.id

        object
      end

      def model_class
        self.model_class
      end

    private
      def self.mongoid?
        get_model_class.included_modules.include?(Mongoid::Document)
      end

      def mongoid?
        self.class.mongoid?
      end

      def set_timestamps
        self.created_at = DateTime.now.utc if self.new_record?
        self.updated_at = DateTime.now.utc
      end
  end
end
