module ActiveRecordQuery
  module Groupable
    extend ActiveSupport::Concern

    class_methods do
      def group_by(*args)
        arg_stacker = ArgumentStacker.new(self, :group_by)
        arg_stacker.add(args)
      end
    end

    included do
      add_feature :build_group_by
    end

    def build_group_by(scope)
      arg_stacker = ArgumentStacker.new(self, :group_by)
      args = arg_stacker.list
      args.present? ? scope.group(*args.flatten) : scope
    end
  end
end
