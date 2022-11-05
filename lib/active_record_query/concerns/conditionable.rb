module ActiveRecordQuery
  module Conditionable
    extend ActiveSupport::Concern

    included do
      include Conditions::Conditionable

      add_feature :build_conditions
    end

    def build_conditions(scope)
      conditions = Conditions::Builder.new(resource, self).build(self)
      conditions ? scope.where(conditions) : scope
    end
  end
end
