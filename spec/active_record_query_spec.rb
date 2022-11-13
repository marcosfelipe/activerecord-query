# frozen_string_literal: true

RSpec.describe ActiveRecordQuery do
  let(:query) { Class.new(described_class::Base) { from Post } }
  let!(:arel_table) { Post.arel_table }

  it "has a version number" do
    expect(ActiveRecordQuery::VERSION).not_to be nil
  end

  it 'is invalid from given a non active record class' do
    expect do
      Class.new(described_class::Base) { from Class.new }
    end.to raise_error(ArgumentError)
  end

  it "executes and returns a ActiveRecord::Relation" do
    expect(query.execute).to be_kind_of(ActiveRecord::Relation)
  end

  describe 'select' do
    it 'projects a column' do
      query.select(query.title)
      expect(query.execute.to_sql).to eq(Post.select(:title).to_sql)
    end

    it 'projects two columns' do
      query.select(query.title, query.body)
      expect(query.execute.to_sql).to eq(Post.select(:title, :body).to_sql)
    end

    it 'projects a math operation' do
      query.select(query.id + query.id)
      expect(query.execute.to_sql).to eq(Post.select(arel_table[:id] + arel_table[:id]).to_sql)
    end

    it 'projects a math operation with dynamic value'
  end

  describe 'order by' do
    it 'orders by a column' do
      query.order_by(query.title.desc)
      expect(query.execute.to_sql).to eq(Post.order(Post.arel_table[:title].desc).to_sql)
    end

    it 'orders by two columns' do
      query.order_by(query.title.desc, query.body.asc)
      expect(query.execute.to_sql).to eq(Post.order(Post.arel_table[:title].desc, Post.arel_table[:body].asc).to_sql)
    end

    it 'orders by a custom order'
  end

  describe 'limit' do
    it 'limits by 10' do
      query.limit(10)
      expect(query.execute.to_sql).to eq(Post.limit(10).to_sql)
    end
  end

  describe 'join' do
    it 'joins another resource' do
      query.join(:author)
      expect(query.execute.to_sql).to eq(Post.joins(:author).to_sql)
    end

    it 'joins multiple resources' do
      query.join(:author)
      query.join(:user)
      expect(query.execute.to_sql).to eq(Post.joins(:author, :user).to_sql)
    end

    it 'defines a resource from the joined table' do
      query.join(:author)
      expect(query.respond_to?(:author)).to be_truthy
    end

    it 'executes where with the joined table' do
      query.join(:author)
      query.where(query.author.name == 'test')
      expect(query.execute.to_sql).to eq(Post.joins(:author).where(Author.arel_table.grouping(Author.arel_table[:name].eq('test'))).to_sql)
    end

    it 'joins Nested Associations (Single Level)' do
      query.join(user: :address)
      expect(query.execute.to_sql).to eq(Post.joins(user: :address).to_sql)
    end

    it 'defines the resources based on Nested Associations' do
      query.join(user: { address: :state })
      %i[user address state].each { |resource| expect(query.respond_to?(resource)).to be_truthy }
    end

    context 'left outer join' do
      let!(:query) { Class.new(described_class::Base) { from User } }

      it 'left outer joins another resource' do
        query.left_outer_join :posts
        expect(query.execute.to_sql).to eq(User.left_outer_joins(:posts).to_sql)
      end

      it 'left outer joins multiple resource' do
        query.left_outer_join :posts
        query.left_outer_join :contacts
        expect(query.execute.to_sql).to eq(User.left_outer_joins(:posts, :contacts).to_sql)
      end

      it 'defines a resource from the joined table' do
        query.left_outer_join :posts
        expect(query.respond_to?(:posts)).to be_truthy
      end

      it 'executes where with the joined table' do
        query.left_outer_join :posts
        query.where(query.posts.title == 'test')
        expect(query.execute.to_sql).to eq(User.left_outer_joins(:posts).where(Post.arel_table.grouping(Post.arel_table[:title].eq('test'))).to_sql)
      end
    end
  end

  describe 'group by' do
    it 'groups by a column' do
      query.group_by(query.title)
      expect(query.execute.to_sql).to eq(Post.group(:title).to_sql)
    end

    it 'groups by a list of columns' do
      query.group_by(query.title, query.body)
      expect(query.execute.to_sql).to eq(Post.group(:title, :body).to_sql)
    end

    it 'groups by with aggregate function' do
      query.select(query.title, query.id.maximum)
      query.group_by(query.title)
      expect(query.execute.to_sql).to eq(Post.select(arel_table[:title], arel_table[:id].maximum).group(:title).to_sql)
    end
  end

  describe 'offset' do
    it 'offsets by 10' do
      query.offset(10)
      expect(query.execute.to_sql).to eq(Post.offset(10).to_sql)
    end
  end

  describe 'having' do
    it 'executes having on created_at column' do
      query.group_by(query.id)
      query.having(query.created_at == query.created_at.maximum)
      expect(query.execute.to_sql).to eq(Post.group(:id).having(arel_table[:created_at].eq(arel_table[:created_at].maximum)).to_sql)
    end

    it 'executes having with aggregate dynamic values' do
      query = Class.new(self.query) do
        select id.sum
        group_by title
        having id.sum.gt :test

        def test
          2
        end
      end
      expect(query.execute.to_sql).to eq(Post.select(arel_table[:id].sum).group(:title).having(arel_table[:id].sum.gt(2)).to_sql)
    end
  end
end
