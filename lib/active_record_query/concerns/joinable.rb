module ActiveRecordQuery
  module Joinable
    extend ActiveSupport::Concern

    class JoinedResource
      def initialize(resource)
        @resource = resource
      end

      def method_missing(m, *args, &block)
        Column.new(Arel::Table.new(resource), m)
      end

      private

      attr_reader :resource
    end

    class_methods do
      def join(*args)
        arg_stacker = ArgumentStacker.new(self, :join)
        arg_stacker.add(args)
        args.to_s.split(/\W+/).compact.each do |resource_name|
          define_singleton_method(resource_name) do
            JoinedResource.new(resource_name.pluralize)
          end
        end
      end
    end

    included do
      add_feature :build_joins
    end

    def build_joins(scope)
      arg_stacker = ArgumentStacker.new(self, :join)
      arg_stacker.list.each do |join_params|
        scope = scope.joins(join_params)
      end
      scope
    end
  end
end
