require 'tab.rb'

class Admin::Cms::CmsController < Admin::BaseController
	before_filter :tab
	access_control :DEFAULT => 'cms'

	private

	def tab
		# TABS : one tab rendered for each tabs objects in @tabs instance variable
		@tabs = [ 
			Tab.new(l('ARTICLES'),"pages","index"),
			Tab.new(l('CATEGORIES'),"categories","index"),
			Tab.new(l('SEARCH'),"search","index")
		]
	end
end
