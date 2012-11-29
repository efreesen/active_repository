module ActiveRepository
  module Finders
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

    def find_by_field(field_name, args)
      self.find_all_by_field(field_name, args).first
    end

    def find_by_id(id)
      if self == get_model_class
        super(id)
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

    def first
      get("first")
    end

    def last
      get("last")
    end

    private
    def get(position)
      if self == get_model_class
        all.sort_by!{ |o| o.id }.send(position)
      else
        object = get_model_class.send(position)
        serialize! object.attributes
      end
    end
  end
end