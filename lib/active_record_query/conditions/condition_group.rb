require_relative 'conditionable'

module ActiveRecordQuery
  # ConditionGroup stacks ChainLink, WhereGroup and WorGroup when
  # 'where' and 'wor' methods are called
  class ConditionGroup
    include Conditions::Conditionable
    cattr_reader :options
  end
end
