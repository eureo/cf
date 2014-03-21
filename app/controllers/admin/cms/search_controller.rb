class Admin::Cms::SearchController < Admin::Cms::CmsController

	def index
	end

	def result
		if request.post?
			@articles = Article.private_search(params[:query])
		else
			redirect_to :action => :index
		end
	end

end
