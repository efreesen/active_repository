require 'pry'

class ActiveRepository::ResultSet
	def initialize(klass, query={}, attributes={})
    @klass = klass
    @query = convert_query(query)
    @attributes = query.is_a?(Hash) ? attributes.merge(query) : attributes
  end

  def all
    get_result(@query)
  end

  def count
    all.size
  end

  def first
    all.first
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
    all.last
  end

  def where(query)
    @attributes = @attributes.merge(query) if query.is_a?(Hash)
    query = and_query(query)

    ActiveRepository::ResultSet.new(@klass, query, @attributes)
  end
  alias_method :and, :where

  def or(query)
    query = or_query(query)

    ActiveRepository::ResultSet.new(@klass, query, @attributes)
  end

private
  def convert_query(query)
    SqlQueryExecutor::Query::QueryNormalizer.clean_query(query)
  end

  def get_result(args)
    if @klass.repository?
      args = args.first if args.is_a?(Array) && args.size == 1
      query_executor = SqlQueryExecutor::Base.new(@klass.all)
      query_executor.where(args)
    else
      objects = PersistenceAdapter.where(@klass, sanitize_args(args)).map do |object|
        @klass.serialize!(object.attributes)
      end

      objects
    end
  end

  def and_query(query)
    query = SqlQueryExecutor::Query::QueryNormalizer.clean_query(query)
    query.blank? ? @query : (@query.blank? ? query : "(#{@query}) and (#{query})")
  end

  def or_query(query)
    query = SqlQueryExecutor::Query::QueryNormalizer.clean_query(query)
    query.blank? ? @query : (@query.blank? ? query : "(#{@query}) or (#{query})")
  end

  def self.sanitize_args(args)
    args.first.is_a?(Hash) ? args.first : (args.first.is_a?(Array) ? args.first : args)
  end
end
