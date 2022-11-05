# frozen_string_literal: true

require 'active_support'
require 'arel'
Dir.glob(File.join(__dir__, 'active_record_query/**/*.rb')) do |f|
  require f
end

module ActiveRecordQuery
  # The base class collects all the activerecord query features
  # and the execute method processes all the features.
  # The api user must inherit from this class in order to build
  # a new query definition.
  class Base
    include Identifiable
    include Featureable
    include Selectable
    include Orderable
    include Limitable
    include Joinable
    include Groupable
    include Offsetable
    include Havingable
    include Conditionable

    class << self
      def execute(options = {})
        new(options).execute
      end
    end

    def initialize(options = {})
      @options = options
    end

    def execute
      query = resource.all
      self.class._query_features.each do |query_feature|
        query = send(query_feature, query)
      end
      query
    end

    private

    attr_reader :options
  end
end
