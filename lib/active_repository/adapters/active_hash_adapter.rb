class ActiveHashAdapter
  class << self
    def all(klass)
      klass.superclass.superclass.all
    end

    def delete_all
      @klass.superclass.delete_all
    end

    def exists?(id)
      @klass.find_by_id(id).present?
    end

    def where(*args)
      query = ActiveHash::SQLQueryExecutor.args_to_query(args)
      @klass.where(query)
    end
  end
end