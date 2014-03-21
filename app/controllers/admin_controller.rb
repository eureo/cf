class AdminController < Admin::BaseController

	def index
		@articles_not_yet_published = Article.find(:all, :conditions => "published = 0 AND archived = 0")
	end
	
end
