module Arel # :nodoc: all
  module Nodes
    # The setter for value is necessary to evaluate
    # when a symbol or proc is passed to it
    class Casted
      attr_writer :value
    end

    # The setter for expr is necessary to evaluate
    # when a symbol or proc is passed to it
    class Unary
      alias :value= :expr=
    end
  end
end
