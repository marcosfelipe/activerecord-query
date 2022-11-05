class Complex2Query < ApplicationQuery
	from Post

	where author == 'T1'

	wor do |g|
		g.where title.like '%Post%'
		g.wor title == 'Bye'
		g.where do |gg|
			gg.where title == 'Test'
			gg.where author == 'Author1'
		end
	end
end
