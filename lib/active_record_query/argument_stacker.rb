module ActiveRecordQuery
  # The stacker class receives a class as context
  # to define instance methods ordered to collect
  # a list of data in the class instance
  class ArgumentStacker
    def initialize(context, stack_name)
      @context = context
      @stack_name = stack_name
    end

    def add(args)
      context.define_method(next_method_name) do
        args
      end
    end

    def list
      stacked_methods.map { |method| context.send(method) }.flatten
    end

    private

    attr_reader :context, :stack_name

    def next_method_name
      current_number = last_stacked_method.to_s.scan(/\d+$/).first.to_i
      "_#{stack_name}_#{current_number + 1}"
    end

    def last_stacked_method
      stacked_methods.last
    end

    def stacked_methods
      context_methods.grep(/^_#{stack_name}_/).sort
    end

    def context_methods
      context.send(context.respond_to?(:instance_methods) ? :instance_methods : :methods)
    end
  end
end
