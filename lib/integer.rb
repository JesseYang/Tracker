class Integer
	def int2hex
    hex = ""
    value = self
    while value != 0
      digit = value % 16
      case digit
      when 0,1,2,3,4,5,6,7,8,9
        hex += digit.to_s
      when 10
        hex += 'A'
      when 11
        hex += 'B'
      when 12
        hex += 'C'
      when 13
        hex += 'D'
      when 14
        hex += 'E'
      when 15
        hex += 'F'
      end
      value = value / 16
    end
    hex.reverse
	end
end
