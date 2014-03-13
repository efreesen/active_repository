# Defines the relations between ActiveRepository objects.
#
# Author::    Caio Torres  (mailto:efreesen@gmail.com)
# License::   GPL

require 'pry'

module ActiveRepository
  module Associations
    def self.included(base)
      base.extend Methods
    end

    module Methods
      # Defines "has many" type relation between ActiveRepository objects
      def has_many(association_id, options = {})
        define_method(association_id) do
          options = {
            class_name:  association_id.to_s.classify,
            foreign_key: self.class.to_s.foreign_key
          }.merge(options)

          klass = options[:class_name].constantize
          objects = []

          klass.where(options[:foreign_key] => id)
        end
      end

      # Defines "has one" type relation between ActiveRepository objects
      def has_one(association_id, options = {})
        options = {
          class_name:  association_id.to_s.classify
        }.merge(options)

        has_one_methods(association_id, options)
      end

      # Defines "belongs to" type relation between ActiveRepository objects
      def belongs_to(association_id, options = {})
        options = {
          class_name:  association_id.to_s.classify,
          foreign_key: association_id.to_s.foreign_key
        }.merge(options)

        field options[:foreign_key].to_sym

        belongs_to_methods(association_id, options)
      end

    private
      def has_one_methods(association_id, options)
        define_has_one_method(association_id, options)
        define_has_one_setter(association_id, options)
        define_has_one_create(association_id, options)
      end

      def belongs_to_methods(association_id, options)
        define_belongs_to_method(association_id, options)
        define_belongs_to_setter(association_id, options)
        define_belongs_to_create(association_id, options)
      end

      def define_has_one_method(association_id, options)
        define_method(association_id) do
          options[:foreign_key] = self.class.to_s.foreign_key

          klass = options[:class_name].constantize

          klass.where(options[:foreign_key] => self.id).first
        end
      end

      def define_has_one_setter(association_id, options)
        define_method("#{association_id}=") do |object|
          options[:foreign_key] = self.class.to_s.foreign_key
          klass = options[:class_name].constantize

          self.send(association_id).update_attribute(options[:foreign_key], nil) if self.send(association_id)

          object.update_attribute(options[:foreign_key], self.send(self.class.primary_key)) if object
        end
      end

      def define_has_one_create(association_id, options)
        define_method("create_#{association_id}") do |attributes|
          options[:foreign_key] = self.class.to_s.foreign_key
          klass = options[:class_name].constantize

          self.send(association_id).update_attribute(options[:foreign_key], nil) if self.send(association_id)
          self.send("#{association_id}=", nil)

          klass.create(attributes.merge(options[:foreign_key] => self.send(self.class.primary_key)))
        end
      end

      def define_belongs_to_method(association_id, options)
        define_method(association_id) do
          klass = options[:class_name].constantize
          id    = send(options[:foreign_key])

          klass.where(klass.primary_key => id).first
        end
      end

      def define_belongs_to_setter(association_id, options)
        define_method("#{association_id}=") do |new_value|
          attributes.delete(association_id.to_sym)
          send("#{options[:foreign_key]}=", (new_value.try(:id) ? new_value.id : new_value))
        end
      end

      def define_belongs_to_create(association_id, options)
        define_method("create_#{association_id}") do |attributes|
          klass = options[:class_name].constantize

          object = klass.create(attributes)

          self.update_attribute(options[:foreign_key], object.id)

          object
        end
      end

    end
  end
end
