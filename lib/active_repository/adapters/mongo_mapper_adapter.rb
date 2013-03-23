require 'active_repository/adapters/default_adapter'

class MongoMapperAdapter < DefaultAdapter
  class << self
    def create(klass, attributes)
      attributes = clean_attributes_id(remove_id(attributes))

      klass.get_model_class.create(attributes)
    end

    def exists?(klass, id)
      klass.get_model_class.where(:id => id).first.present?
    end

    def where(klass, attributes)
      attributes = clean_attributes_id(attributes)

      klass.get_model_class.all(attributes)
    end

    def find(klass, id)
      if id.is_a?(Array)
        objects = []

        id.each do |i|
          objects << klass.get_model_class.find(i.to_s)
        end

        objects
      else
        klass.get_model_class.find(id.to_s)
      end
    end

    def update_attribute(klass, id, key, value)
      unless [:id, :_id].include?(key.to_sym)
        object = id.nil? ? klass.get_model_class.new(key.to_sym => value) : klass.get_model_class.find(id)

        ret = object.update_attribute(key, value)
      else
        object = id.nil? ? klass.get_model_class.create : klass.get_model_class.find(id)
        ret = true
      end

      [ret, object]
    end

    def update_attributes(klass, id, attributes)
      attributes = remove_id(attributes)

      object = id.nil? ? klass.get_model_class.new : klass.get_model_class.find(id)

      ret = object.update_attributes(attributes)

      [ret, object]
    end

    private
    def remove_id(attributes)
      attributes.delete(:id)
      attributes.delete(:_id)
      attributes
    end

    def clean_attributes_id(attributes)
      attributes.each do |key, value|
        attributes[key.to_sym] = value.inspect if value.class.name == "Moped::BSON::ObjectId"
      end

      attributes
    end
  end
end