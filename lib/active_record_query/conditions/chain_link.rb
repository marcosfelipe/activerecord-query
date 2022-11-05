module ActiveRecordQuery
  # Conditions (where or wor) work linking each other,
  # this class identify what are the rules for a link
  ChainLink = Struct.new(:type, :condition, :options)
end
