# Module containing methods responsible for writing attributes of the ActiveRepository::Base class
module ActiveRepository
  module Writers
    # Creates an object and persists it.
    def create(attributes={})
      attributes = attributes.symbolize_keys if attributes.respond_to?(:symbolize_keys)
      object = self.new(attributes)

      if object.present? && object.valid?
        if persistence_class == self
          object.id = nil unless exists?(object.id)

          object.save
        else
          object = PersistenceAdapter.create(self, object.attributes)
        end
      end

      new_object = serialize!(object.reload.attributes)

      new_object.valid?

      new_object
    end

    #:nodoc:
    module InstanceMethods
      # Assigns new_attributes parameter to the attributes in self.
      def attributes=(new_attributes)
        new_attributes.each do |k,v|
          self.send("#{k.to_s == '_id' ? 'id' : k.to_s}=", v)
        end
      end

      # Deletes self from the repository.
      def delete
        klass = self.class
        if klass.persistence_class == klass
          super
        else
          PersistenceAdapter.delete(klass, self.id)
        end
      end

      # Updates #key attribute with #value value.
      def update_attribute(key, value)
        ret = true
        key = key.to_sym

        if self.class == persistence_class
          object = self.class.where(:id => self.id).first_or_initialize

          self.send("#{key}=", value)

          ret = self.save
        else
          ret, object = PersistenceAdapter.update_attribute(self.class, self.id, key, value)

          self.attributes = object.attributes
        end

        reload

        ret
      end

      # Updates attributes in self with the attributes in the parameter
      def update_attributes(attributes)
        attributes  = attributes.symbolize_keys if attributes.respond_to?(:symbolize_keys)
        klass       = self.class
        model_class = persistence_class

        if klass == model_class
          attributes.each do |key, value|
            self.send("#{key}=", value) unless key == :id
          end
          save
        else
          attributes = self.attributes.merge(attributes)
          ret, object = PersistenceAdapter.update_attributes(self.class, self.id, attributes)

          self.attributes = object.attributes
        end

        reload

        ret
      end
    end
  end
end