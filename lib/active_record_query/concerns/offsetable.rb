module ActiveRecordQuery
  module Offsetable
    extend ActiveSupport::Concern

    class_methods do
      def offset(value)
        define_method('offset') do
          value
        end
      end
    end

    included do
      add_feature :build_offset
    end

    def build_offset(scope)
      respond_to?(:offset) ? scope.offset(offset) : scope
    end
  end
end
