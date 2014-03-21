class Admin::Cms::CategoriesController < Admin::Cms::CmsController
	
	access_control [:edit, :new, :delete] => 'cms_admin'
	
	def index
		list
		render_action 'list'
	end

	def list
		@categories = Category.root
	end
	
	def show
		@categories = Category.find_by_permalink(params[:id]) || Category.find(params[:id])
		@articles_not_yet_published = @categories.articles.find(:all, :conditions => "published = 0 AND archived = 0")
		@articles_published = @categories.articles.find(:all, :conditions => "published != 0 AND archived = 0")
		@articles_archived = @categories.articles.find(:all, :conditions => "archived != 0")
	end

	def new
		@categories = Category.find(:all)
		@category = Category.new
		@current_category = params[:category_id].to_i || 0
    if request.post?
			@current_category = params[:category][:parent_id].to_i || params[:category_id].to_i
			parent = Category.find(params[:category][:parent_id])
			@category = parent.children.create(params[:category])
			if @category.save
				flash[:notice] = 'Category was successfully created.'
				redirect_to :controller => 'pages', :action => 'index'
			end
		end
	end
	
	def edit
		@categories = Category.find(:all)
		@category = Category.find_by_permalink(params[:id]) || Category.find(params[:id])
    @category.attributes = params[:category]
    if request.post?
			if @category.save
				flash[:notice] = 'Category was successfully updated.'
				redirect_to :controller => '/admin/cms/categories', :action => 'list'
			else
				flash[:notice] = 'Category was not updated.'
			end
		end
	end
	
	def delete
		@category = Category.find_by_permalink(params[:id]) || Category.find(params[:id])
    if request.post?
      @category.destroy
      flash[:notice] = 'Category was successfully deleted.'
      redirect_to :controller => '/admin/cms/categories', :action => 'list'
    end
	end
	
end
