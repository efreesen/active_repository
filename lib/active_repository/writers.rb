# Module containing methods responsible for writing attributes of the ActiveRepository::Base class
module ActiveRepository
  module Writers
    # Creates an object and persists it.
    def create(attributes={})
      object = get_model_class.new(attributes)

      object.id = nil unless exists?(object.id)

      if get_model_class == self
        object.save
      else
        repository = serialize!(object.attributes)
        object = repository.valid? ? get_model_class.create(attributes) : repository
      end

      object.valid? ? serialize!(object.reload.attributes) : object
    end

    # Searches for an object that matches the attributes on the parameter, if none is found
    # it creates one with the defined attributes.
    def find_or_create(attributes)
      object = get_model_class.where(attributes).first

      object = get_model_class.create(attributes) if object.nil?

      serialize!(object.attributes)
    end

    #:nodoc:
    module InstanceMethods
      # Assigns new_attributes parameter to the attributes in self.
      def attributes=(new_attributes)
        new_attributes.each do |k,v|
          self.send("#{k.to_s == '_id' ? 'id' : k.to_s}=", v)
        end
      end

      # Updates #key attribute with #value value.
      def update_attribute(key, value)
        ret    = self.valid?

        if ret
          object = (self.id.nil? ? self.class.get_model_class.new : self.class.get_model_class.find(self.id))

          if self.class == self.class.get_model_class
            self.send("#{key}=", value)

            ret = save
          else
            key = (key.to_s == 'id' ? '_id' : key.to_s) if mongoid?

            ret = object.update_attribute(key,value)
          end

          reload
        end

        ret
      end

      # Updates attributes in self with the attributes in the parameter
      def update_attributes(attributes)
        ret = true
        klass       = self.class
        model_class = self.class.get_model_class

        if klass == model_class
          attributes.each do |key, value|
            self.send("#{key}=", value) unless key == :id
          end
          save
        else
          object = self.id.nil? ? model_class.new : model_class.find(self.id)

          ret = object.update_attributes(attributes)
        end

        reload
        ret
      end
    end
  end
end