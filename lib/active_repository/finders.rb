# Module containing methods responsible for searching ActiveRepository objects
module ActiveRepository #:nodoc:
  module Finders #:nodoc:
    # Defines fiend_by_field methods for the Class
    def define_custom_find_by_field(field_name)
      method_name = :"find_all_by_#{field_name}"
      the_meta_class.instance_eval do
        define_method(method_name) do |*args|
          object = nil

          object = self.find_by_field(field_name.to_sym, args)

          object.nil? ? nil : serialize!(object.attributes)
        end
      end
    end

    # Defines fiend_all_by_field methods for the Class
    def define_custom_find_all_by_field(field_name)
      method_name = :"find_all_by_#{field_name}"
      the_meta_class.instance_eval do
        define_method(method_name) do |*args|
          objects = []

          objects = self.find_all_by_field(field_name.to_sym, args)

          objects.empty? ? [] : objects.map{ |object| serialize!(object.attributes) }
        end
      end
    end

    # Searches for a object containing the id in #id
    def find(id)
      begin
        if self == get_model_class
          super(id)
        else
          object = (id == :all) ? all : get_model_class.find(id)

          serialize!(object)
        end
      rescue Exception => e
        message = "Couldn't find #{self} with ID=#{id}"
        message = "Couldn't find all #{self} objects with IDs (#{id.join(', ')})" if id.is_a?(Array)

        raise ActiveHash::RecordNotFound.new(message)
      end
    end

    # Searches all objects that matches #field_name field with the #args value(s)
    def find_all_by_field(field_name, args)
      objects = []

      if self == get_model_class
        objects = self.where(field_name.to_sym => args.first)
      else
        if mongoid?
          objects = get_model_class.where(field_name.to_sym => args.first)
        else
          method_name = :"find_all_by_#{field_name}"
          objects = get_model_class.send(method_name, args)
        end
      end

      objects
    end

    # Searches first object that matches #field_name field with the #args value(s)
    def find_by_field(field_name, args)
      self.find_all_by_field(field_name, args).first.dup
    end

    # Searches for an object that has id with #id value, if none is found returns nil
    def find_by_id(id)
      if self == get_model_class
        object = super(id)

        object.nil? ? nil : object.dup
      else
        object = nil

        if mongoid?
          object = get_model_class.where(:id => id).entries.first
        else
          object = get_model_class.find_by_id(id)
        end

        object.nil? ? nil : serialize!(object.attributes)
      end
    end

    # Returns first persisted object
    def first
      self == get_model_class ? super : get(:first)
    end

    # Returns last persisted object
    def last
      self == get_model_class ? super : get(:last)
    end

    private
    # Returns the object in the position specified in #position
    def get(position)
      object = get_model_class.send(position)
      object.present? ? serialize!(object.attributes) : nil
    end
  end
end