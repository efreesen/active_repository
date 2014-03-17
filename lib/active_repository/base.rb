require 'active_repository/associations'
require 'active_repository/uniqueness'
require 'active_repository/write_support'
require 'sql_query_executor'
require 'active_repository/finders'
require 'active_repository/writers'
require 'active_repository/adapters/persistence_adapter'
require 'active_repository/result_set'

module ActiveRepository

  # Base class for ActiveRepository gem.
  # Extends it in order to use it.
  # 
  # == Options
  #
  # There are 2 class attributes to help configure your ActiveRepository class:
  #
  #   * +class_model+: Use it to specify the class that is responsible for the
  #     persistence of the objects. Default is self, so it is always saving in
  #     memory by default.
  #
  #   * +save_in_memory+: Used to ignore the class_model attribute, you can use
  #     it in your test suite, this way all your tests will be saved in memory.
  #     Default is set to true so it saves in memory by default.
  #     
  #
  # == Examples
  #
  # Using ActiveHash to persist objects in memory:
  #
  #   class SaveInMemoryTest < ActiveRepository::Base
  #   end
  #
  # Using ActiveRecord/Mongoid to persist objects:
  #
  #    class SaveInORMOrODMTest < ActiveRepository::Base
  #      SaveInORMOrODMTest.persistence_class = ORMOrODMModelClass
  #      SaveInORMOrODMTest.save_in_memory = false
  #    end
  #
  # Author::    Caio Torres (mailto:efreesen@gmail.com)
  # License::   GPL
  class Base < ActiveHash::Base
    extend ActiveModel::Callbacks
    extend ActiveRepository::Finders
    extend ActiveRepository::Writers
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveRepository::Associations
    include ActiveRepository::Writers::InstanceMethods

    class_attribute :model_class, :instance_writer => false
    class_attribute :save_in_memory, :postfix, :instance_writer => true

    after_validation :set_timestamps

    # Returns all persisted objects
    def self.all
      (repository? ? super : PersistenceAdapter.all(self).map { |object| serialize!(object.attributes) })
    end

    # Constantize class name
    def self.constantize
      self.to_s.constantize
    end

    # Deletes all persisted objects
    def self.delete_all
      repository? ? super : PersistenceAdapter.delete_all(self)
    end

    # Checks the existence of a persisted object with the specified id
    def self.exists?(id)
      repository? ? find_by(id: id).present? : PersistenceAdapter.exists?(self, id)
    end

    def self.persistence_class
      return self if save_in_memory? || (postfix.nil? && self.model_class.nil?)
      return "#{self}#{postfix.classify}".constantize if postfix.present?
      self.model_class.to_s.constantize
    end

    # Returns the Class responsible for persisting the objects
    def self.get_model_class
      puts '[deprecation warning] This method is going to be deprecated, use "persistence_class" instead.'
      persistence_class
    end

    # Searches all objects that matches #field_name field with the #args value(s)
    def self.find_by(args)
      raise ArgumentError("Argument must be a Hash") unless args.is_a?(Hash)

      objects = where(args)

      objects.first
    end

    # Searches all objects that matches #field_name field with the #args value(s)
    def self.find_by!(args)
      object = find_by(args)

      raise ActiveHash::RecordNotFound unless object
      object
    end

    # Converts Persisted object(s) to it's ActiveRepository counterpart
    def self.serialize!(other)
      case other.class.to_s
      when "Hash", "ActiveSupport::HashWithIndifferentAccess" then self.new.serialize!(other)
      when "Array"                                            then other.map { |o| serialize!(o.attributes) }
      when "Moped::BSON::Document", "BSON::Document"          then self.new.serialize!(other)
      else self.new.serialize!(other.attributes)
      end
    end

    # Returns an array with the field names of the Class
    def self.serialized_attributes
      field_names.map &:to_s
    end

    def self.persistence_class=(value)
      self.model_class = value
    end

    # Sets the class attribute model_class, responsible to persist the ActiveRepository objects
    def self.set_model_class(value)
      puts '[deprecation warning] This method is going to be deprecated, use "persistence_class=" instead.'
      persistence_class = value
    end

    def self.save_in_memory?
      self.save_in_memory == nil ? true : self.save_in_memory
    end

    # Sets the class attribute save_in_memory, set it to true to ignore model_class attribute
    # and persist objects in memory
    def self.set_save_in_memory(value)
      puts '[deprecation warning] This method is going to be deprecated, use "save_in_memory=" instead.'
      self.save_in_memory = value
    end

    # Searches persisted objects that matches the criterias in the parameters.
    # Can be used in ActiveRecord/Mongoid way or in SQL like way.
    #
    # Example:
    #
    #   * RelatedClass.where(:name => "Peter")
    #   * RelatedClass.where("name = 'Peter'")
    def self.where(*args)
      raise ArgumentError.new("must pass at least one argument") if args.empty?

      result_set = ActiveRepository::ResultSet.new(self)

      result_set.where(args)

      # if repository?
      #   args = args.first if args.respond_to?(:size) && args.size == 1
      #   query_executor = SqlQueryExecutor::Base.new(all)
      #   query_executor.where(args)
      # else
      #   objects = PersistenceAdapter.where(self, sanitize_args(args)).map do |object|
      #     self.serialize!(object.attributes)
      #   end

      #   objects
      # end
    end

    def persistence_class
      self.class.persistence_class
    end

    def get_model_class
      puts '[deprecation warning] This method is going to be deprecated, use "persistence_class" instead.'
      self.class.persistence_class
    end

    # Persists the object using the class defined on the model_class attribute, if none defined it 
    # is saved in memory.
    def persist
      if self.valid?
        save_in_memory? ? save : self.convert.present?
      end
    end

    # Gathers the persisted object from database and updates self with it's attributes.
    def reload
      object = self.id.present? ? 
                 persistence_class.where(id: self.id).first_or_initialize : 
                 self

      serialize! object.attributes
    end

    def save(force=false)
      if self.class == persistence_class
        object = persistence_class.where(id: self.id).first_or_initialize

        if force || self.id.nil?
          self.id = nil if self.id.nil?
          super
        elsif self.valid?
          object.attributes = self.attributes
          object.save(true)
        end

        self.valid?
      else
        self.persist
      end
    end

    # Updates attributes from self with the attributes from the parameters
    def serialize!(attributes)
      unless attributes.nil?
        attributes.each do |key, value|
          key = "id" if key == "_id"
          self.send("#{key}=", (value.dup rescue value))
        end
      end

      self.dup
    end

    protected
      # Find related object on the database and updates it with attributes in self, if it didn't
      # find it on database it creates a new one.
      def convert(attribute="id")
        klass = persistence_class
        object = klass.where(attribute.to_sym => self.send(attribute)).first

        object ||= persistence_class.new

        attributes = self.attributes

        attributes.delete(:id)

        object.attributes = attributes

        object.save

        self.id = object.id

        object
      end

    private
      def self.repository?
        self == persistence_class
      end

      # Updates created_at and updated_at
      def set_timestamps
        if self.errors.empty?
          self.created_at = DateTime.now.utc if self.respond_to?(:created_at=) && self.created_at.nil?
          self.updated_at = DateTime.now.utc if self.respond_to?(:updated_at=)
        end
      end
  end
end
