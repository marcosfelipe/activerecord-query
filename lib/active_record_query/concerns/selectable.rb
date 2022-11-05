module ActiveRecordQuery
  module Selectable
    extend ActiveSupport::Concern

    class_methods do
      def select(*args)
        arg_stacker = ArgumentStacker.new(self, :select)
        arg_stacker.add(args)
      end
    end

    included do
      add_feature :build_select
    end

    def build_select(scope)
      arg_stacker = ArgumentStacker.new(self, :select)
      args = arg_stacker.list
      args.present? ? scope.select(*args) : scope
    end
  end
end
