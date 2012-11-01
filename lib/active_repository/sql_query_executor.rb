module ActiveHash
  class SQLQueryExecutor
    class << self
      def execute(klass, query)
        case query.split(" ")[1]
        when "="
          query = sanitize_query(query)

          array = query.split(" ")
          sub_query = array[0..3]

          operator = get_operator(sub_query)

          objects = klass.all.select{ |o| o.send(sub_query.first).to_s == sub_query[2].gsub("_", " ") }

          sub_query = query.gsub(sub_query.join(" "), "")

          operator.nil? ? objects : objects.send(operator, execute(klass, sub_query)).sort_by{ |o| o.id }
        else
          []
        end
      end

      def args_to_query(args)
        return args.first if args.size == 1

        query = args.first
        param = args.delete(args[1])

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

        args[0] = query.sub("?", param)

        args_to_query(args)
      end

      private
      def get_operator(attributes)
        operator = attributes.size == 4 ? attributes.last : nil

        case operator
        when "or"
          "+"
        when "and"
          "&"
        else
          nil
        end
      end

      def sanitize_query(query)
        new_query = query
        params = query.scan(/([\"'])(.*?)\1/)

        params.each do |quote, param|
          new_query = query.gsub(quote,"").gsub(param, param.gsub(" ", "_"))
        end

        new_query
      end
    end
  end
end