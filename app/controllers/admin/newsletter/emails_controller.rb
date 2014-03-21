require 'tab.rb'

class Admin::Newsletter::EmailsController < Admin::BaseController
  before_filter :tab
  access_control :DEFAULT => 'email'
  
  
  private
  
  def tab
		# TABS : one tab rendered for each tabs objects in @tabs instance variable
		@tabs = [ 
			Tab.new(l('EMAILS'),"newsletter","index"),
			Tab.new(l('NEWSLETTER'),"html_newsletter","index"),
			Tab.new(l('LISTS'),"list","index"),
			Tab.new(l('IMPORT'),"import","index")
		]
	end
  

end
