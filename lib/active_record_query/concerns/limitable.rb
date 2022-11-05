module ActiveRecordQuery
  module Limitable
    extend ActiveSupport::Concern

    class_methods do
      def limit(value)
        define_method('limit') do
          value
        end
      end
    end

    included do
      add_feature :build_limit
    end

    def build_limit(scope)
      respond_to?(:limit) ? scope.limit(limit) : scope
    end
  end
end
