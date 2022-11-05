module ActiveRecordQuery
  # Extends the Arel attribute class.
  # It sets some aliases for syntactic sugar.
  class Column < Arel::Attributes::Attribute
    alias_method :==, :eq
    alias_method :!=, :not_eq
    alias_method :=~, :matches
    alias_method :>=, :gteq
    alias_method :>, :gt
    alias_method :<, :lt
    alias_method :<=, :lteq
  end
end


