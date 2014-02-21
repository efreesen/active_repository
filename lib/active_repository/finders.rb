# Module containing methods responsible for searching ActiveRepository objects
module ActiveRepository #:nodoc:
  module Finders #:nodoc:
    # Searches for a object containing the id in #id
    def find(id)
      begin
        if repository?
          super(id)
        else
          serialize!(PersistenceAdapter.find(self, id))
        end
      rescue Exception => e
        message = "Couldn't find #{self} with ID=#{id}"
        message = "Couldn't find all #{self} objects with IDs (#{id.join(', ')})" if id.is_a?(Array)

        raise ActiveHash::RecordNotFound.new(message)
      end
    end

    # Returns first persisted object
    def first
      repository? ? super : get(:first)
    end

    # Returns last persisted object
    def last
      repository? ? super : get(:last)
    end

    private
    # Returns the object in the position specified in #position
    def get(position)
      object = PersistenceAdapter.send(position, self)
      object.present? ? serialize!(object.attributes) : nil
    end
  end
end