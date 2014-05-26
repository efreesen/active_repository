module ActiveRepository
  module Callback
    class Base
      def initialize(object, method, options={})
        @object = object
        @method = method
        @options = options
      end

      def call
        @object.send(@method) if can_run?
      end

    private
      def can_run?
        return @can_run if @can_run

        if_option = @options[:if].nil? ? true : @object.send(@options[:if])
        unless_option = @options[:unless].nil? ? false : @object.send(@options[:unless])
        @can_run = if_option && !unless_option
      end
    end
  end
end
