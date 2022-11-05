module ActiveRecordQuery
  # Identifies a type of ConditionGroup with glue set to 'and' operator
  # This class is used whenever a 'where' condition is called with a block
  class WhereGroup < ConditionGroup
    def self.glue
      :and
    end
  end
end
