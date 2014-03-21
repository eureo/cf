class Admin::Newsletter::HtmlNewsletterController < Admin::Newsletter::EmailsController
  
  before_filter :set_page_title
  access_control :DEFAULT => 'email'

  def index
    #@html_job_newsletters = HtmlJobNewsletter.find(:all)
    @newsletters = HtmlNewsletter.find(:all)
  end
  
  def new
    @html_newsletter = HtmlNewsletter.new params[:html_newsletter]

    return unless request.post?
		
    if @html_newsletter.save
      redirect_to :action => "index"
    end
  end
  
  def show
    @html_newsletter = HtmlNewsletter.find(params[:id])
  end
  
  def preview
		@html_newsletter = HtmlNewsletter.find(params[:id])
		render :action => "preview", :layout => "html_newsletter"
	end
  
  def edit
    @html_newsletter = HtmlNewsletter.find(params[:id])

    return unless request.post?
    @html_newsletter.update_attributes(params[:html_newsletter])

		if @html_newsletter.save      
      redirect_to :action => "index"
    end      
  end
  
  def publish
		newsletter = HtmlNewsletter.find(params[:id])
		newsletter.publish
		#newsletter_url = {:controller => '/newsletter', :action => :show, :year => newsletter.published_at.year, :month => sprintf("%.2d", newsletter.published_at.month), :day => sprintf("%.2d", newsletter.published_at.day), :title => newsletter.permalink}
		newsletter_url = {:controller => '/newsletter', :action => :show, :title => newsletter.permalink }
		expire_page newsletter_url
		redirect_to newsletter_url
	end
  
  def show_images
		@images = Image.find(:all)
		render :layout => false
	end
	
	def delete
    HtmlNewsletter.destroy params[:id]
    redirect_to :action => "index"
  end
  
  protected
  
  def set_page_title
    @page_title = "Newsletter"
  end
  
end