module ActiveRecordQuery
  module Conditions
    module Conditionable
      extend ActiveSupport::Concern

      class_methods do
        def where(*args, &block)
          chain_link_definer(Class.new(WhereGroup), args, &block)
        end

        def wor(*args, &block)
          chain_link_definer(Class.new(WorGroup), args, &block)
        end

        def chain_link_definer(group_type, args)
          arg_stacker = ArgumentStacker.new(self, :condition)
          if block_given?
            yield group_type
            arg_stacker.add(group_type)
          else
            condition = args[0]
            options = args[1]
            arg_stacker.add(ChainLink.new(group_type.glue, condition, options))
          end
        end
      end
    end
  end
end
