module ActiveRecordQuery
  # It evaluates an expression to execute on the context
  # whenever a symbol or a proc is passed as value on the expression.
  class ExpressionParser
    def initialize(context)
      @context = context
    end

    def parse(expression)
      if expression.respond_to?(:each)
        expression = expression.map(&:clone)
        expression.each { |arg| parse_arg(arg) }
      else
        expression = expression.clone
        parse_arg(expression)
      end
      expression
    end

    private

    attr_reader :context

    def parse_arg(arg)
      if arg.respond_to?(:right) && arg.right.respond_to?(:value)
        arg.right.value = parse_dynamic_values(arg.right.value)
      end
    end

    def parse_dynamic_values(value)
      if value.is_a?(Symbol)
        context.send(value)
      elsif value.is_a?(Proc)
        context.instance_exec(&value)
      else
        value
      end
    end
  end
end
