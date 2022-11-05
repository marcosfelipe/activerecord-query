module ActiveRecordQuery
  module Havingable
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :_having

      def having(*args)
        arg_stacker = ArgumentStacker.new(self, :having)
        arg_stacker.add(args)
      end
    end

    included do
      add_feature :build_having
    end

    def build_having(scope)
      arg_stacker = ArgumentStacker.new(self, :having)
      args = ExpressionParser.new(self).parse(arg_stacker.list)
      args.present? ? scope.having(*args) : scope
    end
  end
end
