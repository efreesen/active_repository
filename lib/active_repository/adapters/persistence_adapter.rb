require 'active_repository/adapters/default_adapter'
require 'active_repository/adapters/mongoid_adapter'

class PersistenceAdapter
  class << self
    def get_adapter(klass)
      modules = klass.persistence_class.included_modules.map(&:to_s)
      if modules.include?("Mongoid::Document")
        MongoidAdapter
      else
        DefaultAdapter
      end
    end

    def all(klass)
      get_adapter(klass).all(klass)
    end

    def create(klass, attributes)
      get_adapter(klass).create(klass, attributes)
    end

    def delete(klass, id)
      get_adapter(klass).delete(klass, id)
    end

    def delete_all(klass)
      get_adapter(klass).delete_all(klass)
    end

    def exists?(klass, id)
      get_adapter(klass).exists?(klass, id)
    end

    def find(klass, id)
      get_adapter(klass).find(klass, id)
    end

    def first(klass)
      get_adapter(klass).first(klass)
    end

    def last(klass)
      get_adapter(klass).last(klass)
    end

    def update_attribute(klass, id, key, value)
      get_adapter(klass).update_attribute(klass, id, key, value)
    end

    def update_attributes(klass, id, attributes)
      get_adapter(klass).update_attributes(klass, id, attributes)
    end

    def where(klass, args)
      get_adapter(klass).where(klass, args)
    end
  end

  def method_missing(sym, *args, &block)
    get_adapter(args.first).send(sym, args)
  end
end