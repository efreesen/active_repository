class DefaultAdapter
  class << self
    def all(klass)
      klass.get_model_class.all
    end

    def delete_all(klass)
      klass.get_model_class.delete_all
    end

    def exists?(klass, id)
      klass.get_model_class.exists?(id)
    end

    def find(klass, id)
      klass.get_model_class.find(id)
    end

    def first(klass)
      klass.get_model_class.first
    end

    def last(klass)
      klass.get_model_class.last
    end

    def create(klass, attributes)
      object = klass.get_model_class.create(attributes)
    end

    def update_attribute(klass, id, key, value)
      object = id.nil? ? klass.get_model_class.new(key.to_sym => value) : klass.get_model_class.find(id)

      ret = object.update_attribute(key, value)

      [ret, object]
    end

    def update_attributes(klass, id, attributes)
      object = id.nil? ? klass.get_model_class.new : klass.get_model_class.find(id)

      ret = object.update_attributes(attributes)

      [ret, object]
    end

    def where(klass, args)
      klass.get_model_class.where(args)
    end
  end
end