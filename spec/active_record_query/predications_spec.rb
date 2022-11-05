# frozen_string_literal: true

RSpec.describe 'predications' do
  let!(:described_class) { ActiveRecordQuery }
  let!(:query) { Class.new(described_class::Base) { from Post } }
  let!(:arel_table) { Post.arel_table }

  describe 'arel predications' do
    it 'executes the equal' do
      query.where(query.title == 'test')
      expect(query.execute.to_sql).to eq(Post.where(arel_table.grouping(arel_table['title'].eq('test'))).to_sql)
    end

    it 'executes the not equal' do
      query.where(query.title != 'test')
      expect(query.execute.to_sql).to eq(Post.where(arel_table.grouping(arel_table['title'].not_eq('test'))).to_sql)
    end

    it 'executes the not equal any' do
      query.where(query.title.not_eq_any(['test']))
      expect(query.execute.to_sql).to eq(Post.where(arel_table.grouping(arel_table['title'].not_eq_any(['test']))).to_sql)
    end

    it 'executes the match' do
      query.where(query.title =~ 'test')
      expect(query.execute.to_sql).to eq(Post.where(arel_table.grouping(arel_table['title'].matches('test'))).to_sql)
    end

    it 'executes the gteq' do
      query.where(query.id >= 1)
      expect(query.execute.to_sql).to eq(Post.where(arel_table.grouping(arel_table[:id].gteq(1))).to_sql)
    end

    it 'executes the lteq' do
      query.where(query.id <= 1)
      expect(query.execute.to_sql).to eq(Post.where(arel_table.grouping(arel_table[:id].lteq(1))).to_sql)
    end

    it 'executes the in' do
      query.where(query.id.in [1, 2])
      expect(query.execute.to_sql).to eq(Post.where(arel_table.grouping(arel_table[:id].in([1, 2]))).to_sql)
    end
  end

  describe 'dynamic conditions' do
    let(:dyn_where) { Post.where(arel_table.grouping(arel_table[:title].eq(:dynamic))).to_sql }

    it 'executes a dynamic method as condition given a symbol' do
      dyn_query = Class.new(query) do
        where title == :a_test

        def a_test
          'dynamic'
        end
      end
      expect(dyn_query.execute.to_sql).to eq(dyn_where)
    end

    it 'executes a dynamic method as condition given a proc' do
      dyn_query = Class.new(query) do
        where title == proc { a_test }

        def a_test
          'dynamic'
        end
      end
      expect(dyn_query.execute.to_sql).to eq(dyn_where)
    end

    it 'executes a dynamic condition given as execute option' do
      dyn_query = Class.new(query) do
        where title == proc { options[:title] }
      end
      expect(dyn_query.execute(title: 'dynamic').to_sql).to eq(dyn_where)
    end
  end

  describe 'nested predications' do
    it 'executes a grouped OR with AND' do
      query.where do |wr|
        wr.where(query.title == 'test')
        wr.wor(query.title == 'test1')
      end
      query.where(query.body == 'body')
      expected_sql = Post.where(arel_table.grouping(
        arel_table.grouping(arel_table[:title].eq(:test).or(arel_table[:title].eq(:test1)))
                  .and(arel_table[:body].eq(:body))
      )).to_sql
      expect(query.execute.to_sql).to eq(expected_sql)
    end
  end

  describe 'conditional condition' do
    it 'rejects the condition given an if option' do
      query = Class.new(self.query) do
        where id > 1, if: :a_method

        def a_method
          false
        end
      end
      expect(query.execute.to_sql).to eq(Post.all.to_sql)
    end

    it 'supports a proc as condition'
  end
end
