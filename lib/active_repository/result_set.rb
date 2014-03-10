class ActiveRepository::ResultSet
	def initialize(klass, query={}, attributes={})
    @klass = klass
    convert_query(query)
    @attributes = query.is_a?(Hash) ? attributes.merge(query) : attributes
  end

  def all
    @query ? get_result(@query) : @klass.all
  end

  def count
    all.size
  end

  def first
    @query ? all.first : @klass.all.first
  end

  def first_or_initialize
    object = all.first

    object ? object : @klass.new(@attributes)
  end

  def first_or_create
    object = first_or_initialize

    object.new_record? ? object.save : object

    object.reload
  end

  def last
    @query ? all.last : @klass.all.last
  end

  def where(query)
    @attributes = @attributes.merge(query) if query.is_a?(Hash)
    query = join_query(query, 'and')

    ActiveRepository::ResultSet.new(@klass, query, @attributes)
  end
  alias_method :and, :where

  def or(query)
    query = join_query(query, 'or')

    ActiveRepository::ResultSet.new(@klass, query, @attributes)
  end

private
  def convert_query(query)
    @query = SqlQueryExecutor::Query::QueryNormalizer.clean_query(query)
  end

  def get_result(args)
    if @klass.repository?
      args = args.first if args.is_a?(Array) && args.size == 1
      query_executor = SqlQueryExecutor::Base.new(@klass.all, args)
      query_executor.execute!
    else
      query = SqlQueryExecutor::Base.new([], args)
      objects = PersistenceAdapter.where(@klass, query).map do |object|
        @klass.serialize!(object.attributes)
      end

      objects
    end
  end

  def join_query(query, separator)
    query = SqlQueryExecutor::Query::QueryNormalizer.clean_query(query)
    query.blank? ? @query : (@query.blank? ? query : "(#{@query}) #{separator} (#{query})")
  end
end
