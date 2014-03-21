class Tab
	attr_accessor :name
	attr_accessor :controller
	attr_accessor :action

	def initialize(name = "", controller = "", action = "index")
		@name = name
		@controller = controller
		@action = action
	end
	
end
