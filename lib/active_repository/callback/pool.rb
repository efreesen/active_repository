module ActiveRepository
  module Callback
    class Pool
      def initialize
        @pools = {}
      end

      def add(pool, callback)
        return false unless can_add?(pool, callback)

        @pools[pool] ||= []

        @pools[pool] << callback

        true
      end

      def get(pool='')
        @pools[pool] || []
      end

    private
      def can_add?(pool, callback)
        pool && callback.is_a?(Base) && !get(pool).include?(callback)
      end
    end
  end
end
