require 'active_repository/associations'
require 'active_repository/uniqueness'
require 'active_repository/write_support'

module ActiveRepository

  class Base < ActiveHash::Base
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveRepository::Associations

    # TODO: implement first, last, 

    class_attribute :model_class, :save_in_memory

    before_validation :set_timestamps

    fields :created_at, :updated_at

    def self.find(id)
      if self == get_model_class
        super(id)
      else
        object = get_model_class.find(id)

        serialize!(object.attributes)
      end
    end

    def self.find_or_create(attributes)
      object = get_model_class.where(attributes).first

      object = model_class.create(attributes) if object.nil?

      serialize!(object.attributes)
    end

    def self.create(attributes={})
      object = get_model_class.new(attributes)

      object.save

      serialize!(object.attributes) unless object.class.name == self
    end

    def update_attributes(attributes)
      object = self.class.get_model_class.find(self.id)

      attributes.each do |k,v|
        object.send("#{k.to_s}=", v) unless k == :id
      end

      object.save

      self.attributes = object.attributes
    end

    def self.all
      self == get_model_class ? super : get_model_class.all.map { |object| serialize!(object.attributes) }
    end

    def self.delete_all
      self == get_model_class ? super : get_model_class.all.each(&:delete)
    end

    def self.where(query)
      if self == get_model_class
        super
      else
        objects = []
        get_model_class.where(query).each do |object|
          objects << self.serialize!(object.attributes)
        end

        objects
      end
    end

    def self.set_model_class(value)
      self.model_class = value if model_class.nil?
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
      if self == get_model_class
        id = get_model_class.all.map(&:id).sort.first

        self.find_by_id id
      else
        get_model_class.first
      end
    end

    def self.last
      if self == get_model_class
        id = get_model_class.all.map(&:id).sort.last

        self.find id
      else
        get_model_class.last
      end
    end

    def convert(attribute="id")
      object = self.class.get_model_class.send("find_by_#{attribute}", self.send(attribute))
      
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
        self.send("#{k.to_s}=", v)
      end
    end

    def serialize!(attributes)
      unless attributes.nil?
        attributes.each do |k,v|
          self.send("#{k.to_s}=", v)
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
  end
end
