class String
	def hex2int
    value = 0
    index = 0
    self.reverse.each_char do |c|
      case c
      when 'a', 'A'
        v = 10
      when 'b', 'B'
        v = 11
      when 'c', 'C'
        v = 12
      when 'd', 'D'
        v = 13
      when 'e', 'E'
        v = 14
      when 'f', 'F'
        v = 15
      else
        v = c.to_i
      end
      value += v * (16**index)
      index += 1
    end
    value
	end
end
