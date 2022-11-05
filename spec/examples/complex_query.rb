class ComplexQuery < ApplicationQuery
	from Post
	join :user

	where user.name == 'test'

	#select author, title

	#scope OtherComplexQuery

	# static values
	where created_at >= Date.new(2000, 1, 1)
	where author == 'Dennis'
	# wor author == 'John'

	# dynamic values
	where created_at >= :date

	# conditional where
	where title == 'A title', if: :conditional_method

	# simple or
	where title.in %w[Post1 Post2]

	order_by title.asc
	order_by created_at.desc

	# nested or
	wor do |g|
		g.where title == 'Hi'
		g.wor title == 'Bye'
	end

	private

	def date
		options[:date]
	end

	def conditional_method
		options[:with_title]
	end
end
