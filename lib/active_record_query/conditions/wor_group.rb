module ActiveRecordQuery
  # Identifies a type of ConditionGroup with glue set to 'or' operator
  # This class is used whenever a 'wor' condition is called with a block
  class WorGroup < ConditionGroup
    def self.glue
      :or
    end
  end
end
