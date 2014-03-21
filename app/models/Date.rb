class Date
	def age(base = self.class.today)
		base.year - year - ((base.month * 100 + base.day >= month * 100 + day) ? 0 : 1)
	end

end

