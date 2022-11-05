module ActiveRecordQuery
  module Orderable
    extend ActiveSupport::Concern

    class_methods do
      def order_by(*args)
        arg_stacker = ArgumentStacker.new(self, :order_by)
        arg_stacker.add(args)
      end
    end

    included do
      add_feature :build_order
    end

    def build_order(scope)
      arg_stacker = ArgumentStacker.new(self, :order_by)
      args = arg_stacker.list
      args.present? ? scope.order(args) : scope
    end
  end
end
