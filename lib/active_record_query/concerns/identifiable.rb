module ActiveRecordQuery
  module Identifiable
    extend ActiveSupport::Concern

    class_methods do
      def from(model_class)
        raise(ArgumentError, 'Resource must be a ActiveRecord::Base object.') unless model_class.new.is_a?(ActiveRecord::Base)
        define_method(:resource) do
          model_class
        end

        model_class.column_names.each do |column|
          define_singleton_method(column) do
            Column.new(model_class.arel_table, column)
          end
        end
      end
    end
  end
end
