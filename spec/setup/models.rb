require 'active_record'

ActiveRecord::Base.connection.create_table :authors, force: true do |t|
  t.string :name
  t.timestamps
end

ActiveRecord::Base.connection.create_table :users, force: true do |t|
  t.string :name
  t.references :address
  t.timestamps
end

ActiveRecord::Base.connection.create_table :posts, force: true do |t|
  t.references :author
  t.references :user
  t.string :title
  t.text :body
  t.timestamps
end

ActiveRecord::Base.connection.create_table :addresses, force: true do |t|
  t.references :state
  t.string :city
  t.timestamps
end

ActiveRecord::Base.connection.create_table :states, force: true do |t|
  t.string :name
  t.timestamps
end

class Author < ActiveRecord::Base
  has_many :posts
end unless defined?(Author)

class User < ActiveRecord::Base
  has_many :posts
  belongs_to :address
end unless defined?(User)

class Post < ActiveRecord::Base
  belongs_to :author
  belongs_to :user
end unless defined?(Post)

class Address < ActiveRecord::Base
  belongs_to :state
end unless defined?(Address)

class State < ActiveRecord::Base
end unless defined?(State)
