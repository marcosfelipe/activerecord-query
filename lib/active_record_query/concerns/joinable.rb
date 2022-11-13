module ActiveRecordQuery
  # The module defines the join and left_outer_join macros.
  module Joinable
    extend ActiveSupport::Concern

    # The object holds the columns called from a joined resource.
    class JoinedResource
      def initialize(resource)
        @resource = resource
      end

      def method_missing(method_name, *_args, &block)
        Column.new(Arel::Table.new(resource), method_name)
      end

      private

      attr_reader :resource
    end

    class_methods do
      def join(*args)
        arg_stacker = ArgumentStacker.new(self, :join)
        arg_stacker.add(args)
        define_table_resources_from_join(args)
      end

      def left_outer_join(*args)
        ArgumentStacker.new(self, :left_outer_join).add(args)
        define_table_resources_from_join(args)
      end

      def define_table_resources_from_join(join_args)
        join_args.to_s.split(/\W+/).compact.each do |resource_name|
          define_singleton_method(resource_name) do
            JoinedResource.new(resource_name.pluralize)
          end
        end
      end
    end

    included do
      add_feature :build_joins
      add_feature :build_left_outer_joins
    end

    def build_joins(scope)
      arg_stacker = ArgumentStacker.new(self, :join)
      arg_stacker.list.each do |join_params|
        scope = scope.joins(join_params)
      end
      scope
    end

    def build_left_outer_joins(scope)
      arg_stacker = ArgumentStacker.new(self, :left_outer_join)
      arg_stacker.list.each do |join_params|
        scope = scope.left_outer_joins(join_params)
      end
      scope
    end
  end
end
