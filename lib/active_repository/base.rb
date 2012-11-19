require 'active_repository/associations'
require 'active_repository/uniqueness'
require 'active_repository/write_support'
require 'active_repository/sql_query_executor'

module ActiveRepository

  class Base < ActiveHash::Base
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveRepository::Associations

    class_attribute :model_class, :save_in_memory

    before_validation :set_timestamps

    fields :created_at, :updated_at

    def self.define_custom_find_by_field(field_name)
      method_name = :"find_by_#{field_name}"
      unless has_singleton_method?(method_name)
        the_meta_class.instance_eval do
          define_method(method_name) do |*args|
            object = get_model_class.send(method_name)
            object.nil? ? nil : serialize!(object.attributes)
          end
        end
      end
    end

    def self.define_custom_find_by_field(field_name)
      method_name = :"find_by_#{field_name}"
      the_meta_class.instance_eval do
        define_method(method_name) do |*args|
          object = nil

          if self == get_model_class
            object = self.where(field_name.to_sym => args.first).first
          else
            if mongoid?
              object = get_model_class.where(field_name.to_sym => args.first).first
            else
              object = get_model_class.send(method_name, args)
            end
          end

          object.nil? ? nil : serialize!(object.attributes)
        end
      end
    end

    def self.define_custom_find_all_by_field(field_name)
      method_name = :"find_all_by_#{field_name}"
      the_meta_class.instance_eval do
        define_method(method_name) do |*args|
          objects = []

          if self == get_model_class
            objects = self.where(field_name.to_sym => args.first)
          else
            objects = []
            if mongoid?
              objects = get_model_class.where(field_name.to_sym => args.first)
            else
              objects = get_model_class.send(method_name, args)
            end
          end

          objects.empty? ? [] : objects.map{ |object| serialize!(object.attributes) }
        end
      end
    end

    def self.find(id)
      begin
        if self == get_model_class
          super(id)
        else
          object = nil

          if id == :all
            object = all
          else
            object = get_model_class.find(id)
          end

          if object.is_a?(Array)
            object.map { |o| serialize!(o.attributes) }
          else
            serialize!(object.attributes)
          end
        end
      rescue Exception => e
        message = ""

        if id.is_a?(Array)
          message = "Couldn't find all #{self} objects with IDs (#{id.join(', ')})"
        else
          message = "Couldn't find #{self} with ID=#{id}"
        end

        raise ActiveHash::RecordNotFound.new(message)
      end
    end

    def reload
      serialize! self.class.get_model_class.find(self.id).attributes
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

    def self.find_by_id(id)
      if self == get_model_class
        super(id)
      else
        if mongoid?
          get_model_class.where(:id => id).entries.first
        else
          get_model_class.find_by_id(id)
        end
      end
    end

    def self.find_or_create(attributes)
      object = get_model_class.where(attributes).first

      object = model_class.create(attributes) if object.nil?

      serialize!(object.attributes)
    end

    def self.create(attributes={})
      object = get_model_class.new(attributes)

      object.id = nil if exists?(object.id)

      if get_model_class == self
        object.save
      else
        repository = serialize!(object.attributes)
        repository.valid? ? (object = get_model_class.create(attributes)) : false
      end

      serialize!(object.attributes) unless object.class.name == self
    end

    def update_attributes(attributes)
      object = nil
      if mongoid?
        object = self.class.get_model_class.find(self.id)
      else
        object = self.class.get_model_class.find(self.id)
      end

      attributes.each do |k,v|
        object.update_attribute("#{k.to_s}", v) unless k == :id
      end

      self.reload
    end

    def update_attribute(key, value)
      if self.class == self.class.get_model_class
        super(key,value)
      else
        object = self.class.get_model_class.find(self.id)

        if mongoid?
          super(key,value)
          key = key.to_s == 'id' ? '_id' : key.to_s
        end

        object.update_attribute(key, value)
        object.save
      end

      self.reload
    end

    def self.all
      self == get_model_class ? super : get_model_class.all.map { |object| serialize!(object.attributes) }
    end

    def self.delete_all
      puts self.inspect
      puts get_model_class.inspect
      self == get_model_class ? super : get_model_class.delete_all
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

    def persist
      if self.valid?
        save_in_memory? ? save : self.convert
      end
    end

    def self.first
      get("first")
    end

    def self.last
      get("last")
    end

    def self.get(position)
      if self == get_model_class
        id = get_model_class.all.map(&:id).sort.send(position)

        self.find id
      else
        serialize! get_model_class.send(position).attributes
      end
    end

    def convert(attribute="id")
      object = nil

      if mongoid?
        object = self.class.where(attribute.to_sym => self.send(attribute)).first
      else
        object = self.class.get_model_class.send("find_by_#{attribute}", self.send(attribute))
      end
      
      object = self.class.get_model_class.new if object.nil?

      self.attributes.each do |k,v|
        object.send("#{k.to_s}=", v) unless k == :id
      end

      object.save

      self.id = object.id

      object
    end

    def attributes=(new_attributes)
      new_attributes.each do |k,v|
        self.send("#{k.to_s == '_id' ? 'id' : k.to_s}=", v)
      end
    end

    def serialize!(attributes)
      unless attributes.nil?
        attributes.each do |k,v|
          self.send("#{k.to_s == '_id' ? 'id' : k.to_s}=", v)
        end
      end

      self
    end

    def self.serialize!(attributes)
      object = self.new

      object.serialize!(attributes)
    end

    def self.serialized_attributes
      field_names.map &:to_s
    end

    def self.constantize
      self.to_s.constantize
    end

    def self.get_model_class
      save_in_memory? ? self : self.model_class
    end

    protected
      def model_class
        self.model_class
      end

    private
      def set_timestamps
        self.created_at = DateTime.now.utc if self.new_record?
        self.updated_at = DateTime.now.utc
      end

      def self.mongoid?
        get_model_class.included_modules.include?(Mongoid::Document)
      end

      def mongoid?
        self.class.mongoid?
      end
  end
end
