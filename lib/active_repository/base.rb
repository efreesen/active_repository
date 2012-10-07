require 'active_repository/associations'
require 'active_repository/uniqueness'

module ActiveRepository

  class Base < ActiveHash::Base
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveRepository::Associations

    # TODO: implement first, last, 

    class_attribute :model_class

    before_validation :set_timestamps

    fields :created_at, :updated_at

    def self.find_or_create(attributes)
      object = get_model_class.where(attributes).first

      object = model_class.create(attributes) if object.nil?

      serialize!(object.attributes)
    end

    def self.all
      self == get_model_class ? super : get_model_class.all
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

    def set_model_class(value)
      self.model_class = value if Rails.env == 'test' || self.model_class.nil?
    end

    def persist
      if self.valid?
        Settings.save_in_memory ? save : self.convert
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
      Settings.save_in_memory ? self : self.model_class
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
