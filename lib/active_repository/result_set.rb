class ActiveRepository::ResultSet
	def initialize(klass, query={}, attributes={})
    @klass = klass
    convert_query(query)
    @attributes = attributes.merge(SqlQueryExecutor::Query::Normalizers::QueryNormalizer.attributes_from_query(query))
  end

  def all
    @query ? get_result(@query) : @klass.all
  end

  def each(&block)
    all.each(&block)
  end

  def empty?
    all.empty?
  end

  def any?
    all.any?
  end

  def map(&block)
    all.map(&block)
  end

  def pluck(attribute)
    all.map(&attribute)
  end

  def build(attributes)
    @klass.new(@attributes.merge(attributes))
  end

  def create(attributes)
    @klass.create(@attributes.merge(attributes))
  end

  def count
    all.size
  end

  def first
    @query ? all.first : @klass.first
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
    @query ? all.last : @klass.last
  end

  def where(query)
    @attributes = @attributes.merge(SqlQueryExecutor::Query::Normalizers::QueryNormalizer.attributes_from_query(query))
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
    @query = SqlQueryExecutor::Query::Normalizers::QueryNormalizer.clean_query(query)
  end

  def get_result(args)
    if @klass.repository?
      args = args.first if args.is_a?(Array) && args.size == 1
      query_executor = SqlQueryExecutor::Base.new(args)
      query_executor.execute!(@klass.all)
    else
      query = SqlQueryExecutor::Base.new(args)
      objects = PersistenceAdapter.where(@klass, query).map do |object|
        @klass.serialize!(object.attributes)
      end

      objects
    end
  end

  def join_query(query, separator)
    query = SqlQueryExecutor::Query::Normalizers::QueryNormalizer.clean_query(query)
    query.blank? ? @query : (@query.blank? ? query : "(#{@query}) #{separator} (#{query})")
  end
end
