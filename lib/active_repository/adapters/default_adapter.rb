class DefaultAdapter
  class << self
    def all(klass)
      klass.persistence_class.all
    end

    def delete(klass, id)
      object = klass.persistence_class.where(id: id).first
      object.delete if object
    end

    def delete_all(klass)
      klass.persistence_class.delete_all
    end

    def exists?(klass, id)
      klass.persistence_class.exists?(id)
    end

    def find(klass, id)
      id = normalize_id(id) if id

      klass.persistence_class.find(id)
    end

    def first(klass)
      klass.persistence_class.first
    end

    def last(klass)
      klass.persistence_class.last
    end

    def create(klass, attributes)
      object = klass.persistence_class.create(attributes)
    end

    def update_attribute(klass, id, key, value)
      object = id.nil? ? klass.persistence_class.new(key.to_sym => value) : klass.persistence_class.find(id)

      ret = object.update_attribute(key, value)

      [ret, object]
    end

    def update_attributes(klass, id, attributes)
      object = id.nil? ? klass.persistence_class.new : klass.persistence_class.find(id)

      ret = object.update_attributes(attributes)

      [ret, object]
    end

    def where(klass, query)
      klass.persistence_class.where(query.to_sql)
    end

  private
    def normalize_id(args)
      return args if args.is_a?(Array)
      
      id = (args.is_a?(Hash) ? args[:id] : args)

      convertable?(id) ? id.to_i : id
    end

    def convertable?(id)
      id.respond_to?(:to_i) && id.to_s == id.to_i.to_s
    end
  end
end