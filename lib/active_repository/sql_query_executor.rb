module ActiveHash
  class SQLQueryExecutor
    class << self
      def args_to_query(args)
        return args.first if args.size == 1

        query = args.first
        param = args.delete(args[1])

        param = convert_param(param)

        args[0] = query.sub("?", param)

        args_to_query(args)
      end

      def execute(klass, query)
        @operator, @sub_query, @objects = process_first(klass, query, query.split(" ")[1])

        @operator.nil? ? @objects : @objects.send(@operator, execute(klass, @sub_query)).sort_by{ |o| o.id }
      end

      private
      def divide_query
        array = @query.split(" ")
        case @operator
        when "between"
          array[0..5]
        when "is"
          size = array[2].downcase == "not" ? 4 : 3
          array[0..size]
        else
          array[0..3]
        end
      end

      def convert_attrs(field, *attrs)
        attrs.each_with_index do |attribute, i|
          attribute = attribute.gsub("_", " ")
          attrs[i] = field.is_a?(Integer) ? attribute.to_i : attribute
        end

        field = field.is_a?(Integer) ? field : field.to_s

        [field, attrs].flatten
      end

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

      def execute_between(klass, sub_query)
        klass.all.select do |o|
          field, first_attr, second_attr = convert_attrs(o.send(sub_query.first), sub_query[2], sub_query[4])

          (field >= first_attr && field <= second_attr)
        end
      end

      def execute_is(klass, sub_query)
        klass.all.select do |o|
          field = o.send(sub_query.first).blank?

          sub_query.size == 3 ? field : !field
        end
      end

      def execute_operator(klass, sub_query)
        klass.all.select do |o|
          field, attribute = convert_attrs(o.send(sub_query.first), sub_query[2])

          field.blank? ? false : field.send(@operator, attribute)
        end
      end

      def execute_sub_query(klass, sub_query)
        case @operator
        when "between"
          execute_between(klass, sub_query)
        when "is"
          execute_is(klass, sub_query)
        else
          execute_operator(klass, sub_query)
        end
      end

      def get_operator(attributes)
        operator = attributes.size >= 4 ? attributes.last : nil

        case operator
        when "or"  then "+"
        when "and" then "&"
        else nil
        end
      end

      def process_first(klass, query, operator)
        @operator = operator == "=" ? "==" : operator
        @query    = sanitize_query(query)
        sub_query = divide_query

        binding_operator = get_operator(sub_query)

        objects = execute_sub_query(klass, sub_query)

        sub_query = query.gsub(sub_query.join(" "), "")

        [binding_operator, sub_query, objects]
      end

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