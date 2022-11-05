# ActiveRecordQuery

ActiveRecordQuery is a DSL buit on top of [ActiveRecord](https://github.com/rails/rails/tree/main/activerecord) 
to help you write complex SQL queries 
in the cleanest way possible. The lib provides a base class to 
build a query pattern in your object oriented project.

Quick usage sample:

```ruby
# verbose
query = Post.joins(:author).where(Post.arel_table[:created_at].gt(Date.new(2000, 1, 2))).order(title: :asc)

# clean ;)
class Query < ActiveRecordQuery::Base
  from Post
  join :author
  where created_at > Date.new(2000, 1, 2)
  order_by title.asc, author.name.asc
end
query = Query.execute
```

The main goal is to turn your queries (or scopes) into classes.
These classes will be written naturally like a SQL query using a ruby DSL.
The common problem with the actual design of activerecord is that 
the users tend to write the query features in chain, like this:

```ruby
Post.select(:title)
    .where(title: 'A title')
    .where('created_at > ?', Date.today)
    .order(:title)
```

You can refactor with scopes, I guess..

```ruby
class Post < ActiveRecord::Base
  scope :titled, -> { where(title: 'A title') }
  scope :created, -> { where('created_at < ?', Date.today) }
  scope :titled_created, -> { titled.created }
  
  def self.a_query
    select(:title).titled_created.order(:title)
  end
end
```

Very messy...
When arel table features comes in, it becomes even worst.

```ruby
is_fixed = Post[:fixed].eq(true)
is_coming = Post[:coming].eq(true).and(Post[:activated_at].not_eq(nil))
Post.where(is_fixed.or(is_coming))
```

Now, let's try the ActiveRecordQuery:

```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  where fixed == true
  wor do |other|
    other.where coming == true
    other.where actived_at != nil
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-query'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activerecord-query

## Usage

ActiveRecordQuery adds the ActiveRecord::Base class to your project, 
so we can easily create query classes by extending it.

### Queries
The concept is given by the notion of query pattern classes. 
The suggestion is that you put these classes in app/queries folder. 

### The query setup

Consider to have a Post model:

```ruby
class Post < ActiveRecord::Base
end
```

Now, you have to create a classe extending `ActiveRecordQuery::Base` class, 
and then add the reference for the `Post` activerecord type 
on `from` method.

```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
end
```

Once you have defined the from resource, the columns from Post will be available 
as methods in the class scope. 
E.g. the method `title` will be defined as a `Arel::Attributes::Attribute` object.

```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  select title # the 'title' method was defined from 'from'
end
```

The public method `execute` will return the `ActiveRecord_Relation` object.
```ruby
PostQuery.execute # => ActiveRecord_Relation 
```

Or you can instantiate it also:
```ruby
PostQuery.new.execute # => ActiveRecord_Relation 
```

### Query Features

#### Conditions
The methods `where` and `wor` are available to set the query conditions.
The argument must be a `Arel::Node` object. 
To a cleaner experience, you can use the generated methods for columns 
generated from the `from` method.

```ruby
class PostQuery < ActiveRecordQuery::Base 
  from Post
  
  # and operation
  where title == 'something' # using title helper
  where Post.arel_table[:title].eq('something') # using arel
    
  # or operation
  wor title == 'something else'
end
```

The Arel predications are available:

```ruby
# between
where column.between 1..10

# matches
where column.matches '%something%'

# not in all
where column.not_in_all %w[something]
```

You can nest the conditions:
```ruby
where column == 'c1'
wor do |nested|
  nested.where column == 'c2'
  nested.where other == 'c3'
  nested.wor do |deep_nested|
    deep_nested.where other == 'c1'
    deep_nested.where column == 'c4'
  end
end
```
It Generates:
```sql
column = "c1" or (column = "c2" and other = "c3" or (other = 'c1' and column = 'c4'))
```

The dynamic values for conditions can be add as a symbol to reference 
a method or can be a proc. The values will be evaluate when the `execute` is called.

```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  where title == :a_dynamic_method # references a method
  where title == proc { 'a title' } # the value will be evaluate on execute
  
  def a_dynamic_method
    'a title'
  end
end
```

#### Conditional where
The `where/wor` state can be conditioned by passing the option `if:`.
The value must be a symbol referencing a method.
```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  where title == 'test', if: :a_method?
  
  def a_method?
    false
  end
end
```

#### Selects
Selects can be done by passing a list of columns to the `select` method.
The args must be a list of `Arel::Attributes::Attribute`. 
If no select is defined in the query, then the `*` selection will be taken.
Every call of `select` the attrs will be added to the selection. 

```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  
  # simple select
  select title, created_at
  
  # can do a math op (it's just a arel attr)
  select id + id   
  
  # plain arel attr
  select Post.arel_table[:id]
end
```

#### Order by
Much like the select method, you shall pass a list of attributes to the method `order_by`.
Every call of `order_by` the attrs will be added to the selection.

```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  
  # list of arel attrs
  order_by title.asc, created_at.desc
end
```

#### Limits
The `limit` method is available to define a query limit.
An integer value is the only arg acceptable.
Every time the limit method is called, the limit will be redefined.
```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  limit 10
end
```

#### Offsets
The `offset` method is available to define a query offset.
An integer value is the only arg acceptable.
Every time the offset method is called, the offset will be redefined.
```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  offset 10
end
```

#### Joins
The `join` method defines one/many relationships with the current resource (`from` state).
The following example has a Post and Author models, the way we define a join is the same as 
defining a `joins` on activerecord (check the active record querying doc.).
Right after defined the join a new method will be available for retrieve the columns 
from the new resource, the `author` method on this example. Every relationship listed in 
the args will be converted to a method with the same name.
```ruby
# models
class Post < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  has_many :posts
end

# query
class PostQuery < ActiveRecordQuery::Base
  from Post
  join :author
  
  # the author helper will be available
  where author.name == 'John'
end
```


#### Group by
To apply a GROUP BY clause to the query, you can use the `group_by` method.
The method accepts a list of columns.
```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  group_by title
end
```

#### Having
You can add the HAVING clause to the query by defining a `having` method.
A column condition can be done by calling the Arel predication methods like `gt`. 
```ruby
class PostQuery < ActiveRecordQuery::Base
  from Post
  group_by title
  having id.gt 5
end
```


### Scopes
There are at least to ways to scope your query class. The first one is the use of 
class inheritance. The second one is extract features to modules. 

#### Class inheritance
You can merge queries by extending the class. 
Let's say that you have a base query definition `AScopeQuery`.

```ruby
class AScopeQuery < ApplicationQuery
  from Post
  where title != nil
end
```
And then you extend this query:
```ruby
class AQuery < AScopeQuery
  where id > 5
  order_by title
end
```
The result will be the merge of the two queries:
```sql
SELECT * FROM posts WHERE title NOT NULL AND id > 5 ORDER BY title 
```

#### Modules
Another way to scope a query, would be including modules into yours 
query class. Let's define a module with activesupport concern.

```ruby
module AScope
  extend ActiveSupport::Concern
  
  included do
    where title == 'a scope'
  end
end
```
Note that we called the `where` macro inside the included method just like the 
"activemodel concerns style". And then we can simply include the scope module into 
the query class:
```ruby
class AQuery < ApplicationQuery
  from Post
  include AScope
end
```
It is important to notice that the module must be included after the `from` definition
due to the scope dependency on the `from` builds.

### Query Parameters
The query class can be instantiate/execute with user parameters. 
The `options` method will be available on the instance context of the class.
This data can be part of the query dynamic solutions in their features.
```ruby
class PostQuery < ApplicationQuery
  from Post
  where title == :title_value
  
  def title_value
    options[:title]
  end
end

# execute with option :title
PostQuery.execute(title: 'A Title') # => select * from posts where title = "A Title"
```
On this example, the value for title condition is dynamic set by 
the `options` parameter. A proc can be used also:
```ruby
where title == proc { options[:title] }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/marcosfelipe/activerecord-query. 
This project is intended to be a safe, 
welcoming space for collaboration, and contributors are 
expected to adhere to the [code of conduct](https://github.com/rubygems/rubygems/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveRecordQuery project's codebases, issue trackers, chat rooms and mailing lists is 
expected to follow the [code of conduct](https://github.com/rubygems/rubygems/blob/master/CODE_OF_CONDUCT.md).
