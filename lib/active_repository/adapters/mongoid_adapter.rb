require 'active_repository/adapters/default_adapter'

class MongoidAdapter < DefaultAdapter
  class << self
  #   def all(klass)
  #     klass.all
  #   end

  #   def delete_all(klass)
  #     klass.delete_all
  #   end

    def exists?(klass, id)
      klass.persistence_class.where(:id => id).present?
    end

  #   def find(klass, id)
  #     klass.find(id)
  #   end

  #   def first(klass)
  #     klass.first
  #   end

  #   def last(klass)
  #     klass.last
  #   end

  #   def create(klass, attributes)
  #     klass.create(attributes)
  #   end

  #   def update_attribute(klass, id, key, value)
  #     object = id.nil? ? klass.new(key.to_sym => value) : klass.find(id)

  #     ret = object.update_attribute(key, value)

  #     [ret, object]
  #   end

  #   def update_attributes(klass, id, attributes)
  #     object = id.nil? ? klass.new : klass.find(id)

  #     ret = object.update_attributes(attributes)

  #     [ret, object]
  #   end

    def where(klass, query)
      klass.persistence_class.where(query.selector)
    end
  end
end