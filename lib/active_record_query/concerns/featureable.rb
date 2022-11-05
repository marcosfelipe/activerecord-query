module ActiveRecordQuery
  module Featureable
    extend ActiveSupport::Concern

    class_methods do
      def _query_features
        @@_query_features
      end

      def add_feature(feature)
        @@_query_features ||= []
        @@_query_features << feature
      end
    end
  end
end
