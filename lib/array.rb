class Array
	def serialize
		ser_ary = []
		self.each do |ele|
			case ele.class
			when Survey
				ser_ary << ele.serialize
			else
				ser_ary << ele
			end
		end
	end

	def mean
		return 0 if self.length == 0
		return self.sum.to_f / self.length
	end

end
