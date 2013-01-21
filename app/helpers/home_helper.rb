module HomeHelper
	def alternating_row
		res = ""
		if(@row_count%2 > 0)
			res = "odd"
		else
			res = "even"
		end

		@row_count += 1
		return res
	end
end