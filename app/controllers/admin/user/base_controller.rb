require 'tab.rb'

class Admin::User::BaseController < Admin::BaseController
	before_filter :tab
	access_control :DEFAULT => 'admin'

	private
	def tab
		# TABS : one tab rendered for each tabs objects in @tabs instance variable
		@tabs = [ 
			Tab.new(l('USERS'),"user","index")
		]
	end

end
