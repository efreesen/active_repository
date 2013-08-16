# Defines the relations between ActiveRepository objects and/or ActiveRecord Models.
#
# Author::    Caio Torres  (mailto:efreesen@gmail.com)
# License::   MIT

module ActiveRepository
  module Associations
    #:nodoc:
    module ActiveRecordExtensions
      # Defines belongs to type relation between ActiveRepository objects and ActivRecord Models.
      def belongs_to_active_repository(association_id, options = {})
        options = {
          class_name:  association_id.to_s.classify,
          foreign_key: association_id.to_s.foreign_key
        }.merge(options)

        define_method(association_id) do
          options[:class_name].constantize.find_by_id(send(options[:foreign_key]))
        end

        define_method("#{association_id}=") do |new_value|
          send "#{options[:foreign_key]}=", new_value ? new_value.id : nil
        end

        create_reflection(
            :belongs_to,
            association_id.to_sym,
            options,
            options[:class_name].constantize
          )
      end
    end

    #:nodoc:
    def self.included(base)
      base.extend Methods
    end

    #:nodoc:
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

          if klass.respond_to?(:scoped)
            objects = klass.scoped(:conditions => {options[:foreign_key] => id})
          else
            objects = klass.send("find_all_by_#{options[:foreign_key]}", id)
          end
        end
      end

      # Defines "has one" type relation between ActiveRepository objects
      def has_one(association_id, options = {})
        define_method(association_id) do
          options = {
            class_name:  association_id.to_s.classify,
            foreign_key: self.class.to_s.foreign_key
          }.merge(options)

          scope = options[:class_name].constantize

          if scope.respond_to?(:scoped) && options[:conditions]
            scope = scope.scoped(:conditions => options[:conditions])
          end
          
          scope.send("find_by_#{options[:foreign_key]}", id)
        end
      end

      # Defines "belongs to" type relation between ActiveRepository objects
      def belongs_to(association_id, options = {})
        options = {
          class_name:  association_id.to_s.classify,
          foreign_key: association_id.to_s.foreign_key
        }.merge(options)

        field options[:foreign_key].to_sym

        define_method(association_id) do
          klass = options[:class_name].constantize
          id    = send(options[:foreign_key])

          if id.present?
            object = klass.find_by_id(id)
          else
            nil
          end
        end

        define_method("#{association_id}=") do |new_value|
          attributes.delete(association_id.to_sym)
          send("#{options[:foreign_key]}=", (new_value.try(:id) ? new_value.id : new_value))
        end
      end
    end
  end
end
