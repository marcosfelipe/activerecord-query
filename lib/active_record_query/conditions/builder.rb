module ActiveRecordQuery
  module Conditions
    class Builder
      def initialize(resource, context)
        @resource = resource
        @context = context
      end

      def build(group)
        chain_conditions = nil
        arg_stacker = ArgumentStacker.new(group, :condition)
        arg_stacker.list.each do |chain_link|
          next unless executable?(chain_link)
          if chain_link.respond_to?(:where)
            group = chain_link.new
            chain_conditions = chain_conditions.present? ? chain_conditions.send(chain_link::glue, build(group)) : build(group)
          else
            arel_condition = ExpressionParser.new(context).parse(chain_link.condition)
            chain_conditions = chain_conditions.present? ? chain_conditions.send(chain_link.type, arel_condition) : arel_condition
          end
        end
        resource.arel_table.grouping(chain_conditions) if chain_conditions
      end

      private

      attr_reader :resource, :context

      def executable?(chain_link)
        condition_options = chain_link.options.to_h
        return true unless condition_options[:if].present?
        context.send(condition_options[:if])
      end
    end
  end
end
