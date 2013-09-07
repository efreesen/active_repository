# Simulates a SQL where clause to filter objects from the database
module ActiveHash #:nodoc:
  class SQLQueryExecutor #:nodoc:
    class << self #:nodoc:
      # Prepares query by replacing all ? by it's real values in #args
      def args_to_query(args)
        return args.first if args.size == 1

        query = args.first
        param = args.delete_at(1)

        param = convert_param(param)

        args[0] = query.sub("?", param)

        args_to_query(args)
      end

      # Recursive method that divides the query in sub queries, executes each part individually
      # and finally relates its results as specified in the query.
      def execute(klass, query)
        query = query.gsub(/\[.*?\]/) { |substr| substr.gsub(' ', '') }

        @operator, @sub_query, @objects = process_first(klass, query, query.split(" ")[1].downcase)

        @operator.nil? ? @objects : @objects.send(@operator, execute(klass, @sub_query)).sort_by{ |o| o.id }
      end

    private
      # Splits the first sub query from the rest of the query and returns it.
      def divide_query
        array = @query.split(" ")
        case @operator
        when "between"
          array[0..5]
        when "is"
          size = array[2] == "not" ? 4 : 3
          array[0..size]
        else
          array[0..3]
        end
      end

      # Replaces white spaces for underscores inside quotes in order to avoid getting parameters
      # split into separate components of the query.
      def convert_attrs(field, *attrs)
        attrs.each_with_index do |attribute, i|
          attribute = attribute.gsub("_", " ") rescue attribute
          attrs[i] = field.is_a?(Integer) ? attribute.to_i : attribute
        end

        field = field.is_a?(Integer) ? field : field.to_s

        [field, attrs].flatten
      end

      # Returns converted #param based on its Class, so it can be used on the query
      def convert_param(param)
        case param.class.name
        when "String"
          param = "'#{param}'"
        when "Date"
          param = "'#{param.strftime("%Y-%m-%d")}'"
        when "Time"
          param = "'#{param.strftime("%Y-%m-%d %H:%M:%S %z")}'"
        else
          param = param.to_s
        end
      end

      # Execute SQL between filter
      def execute_between(klass, sub_query)
        klass.all.select do |o|
          field = sub_query.first.gsub('(', '')
          field, first_attr, second_attr = convert_attrs(o.send(field), sub_query[2], sub_query[4])

          (field >= first_attr && field <= second_attr)
        end
      end

      # Executes SQL is filter
      def execute_is(klass, sub_query)
        klass.all.select do |o|
          field = o.send(sub_query.first).blank?

          sub_query.size == 3 ? field : !field
        end
      end

      # Executes SQL is filter
      def execute_in(klass, sub_query)
        klass.all.select do |o|
          field = o.send(sub_query.first)
          values = sub_query[2].gsub(/\(|\[|\]|\)/, '').split(/,|, /)
          
          values.include?(field.to_s)
        end
      end

      # Executes the #sub_quey defined operator filter
      def execute_operator(klass, sub_query)
        klass.all.select do |o|
          query = sub_query.first

          if query
            field, attribute = convert_attrs(o.send(query.gsub(/[\(\)]/, "")), sub_query[2])

            field.blank? ? false : field.send(@operator, attribute)
          else
            false
          end
        end
      end

      # Executes the #sub_query
      def execute_sub_query(klass, sub_query)
        case @operator
        when "between"
          execute_between(klass, sub_query)
        when "is"
          execute_is(klass, sub_query)
        when "in"
          execute_in(klass, sub_query)
        else
          execute_operator(klass, sub_query)
        end
      end

      # Converts SQL where clause sub query operator to its Ruby Array counterpart
      def get_operator(attributes)
        operator = attributes.size >= 4 ? attributes.last : nil

        case operator.try(:downcase)
        when "or"  then "+"
        when "and" then "&"
        else nil
        end
      end

      # Processes the first sub query in query
      def process_first(klass, query, operator)
        @operator = (operator == "=" ? "==" : (operator == '<>' ? '!=' : operator))
        @query    = sanitize_query(query)
        sub_query = divide_query

        binding_operator = get_operator(sub_query)

        objects = execute_sub_query(klass, sub_query)

        query_array = query.split(' ')

        sub_query = query_array[sub_query.size..query_array.size].join(' ')

        [binding_operator, sub_query, objects]
      end

      # Removes all accents and other non default characters
      def sanitize_query(query)
        new_query = query
        params = query.scan(/([\"'])(.*?)\1/)

        params.each do |quote, param|
          new_query = new_query.gsub(quote,"").gsub(param, param.gsub(" ", "_"))
        end

        new_query
      end
    end
  end
end