class Admin::Cms::PagesController < Admin::Cms::CmsController
  
  access_control [:publish, :unpublish, :archive, :unarchive, :delete ] => 'cms_admin'
  
  cache_sweeper :article_sweeper, :only => [:new, :edit, 
    :tag, :publish, :unpublish, :archive, :unarchive, :delete, :upload_image, :upload_attachment]

  def index
    @categories = Category.root
    taggings = Tagging.find_all_by_taggable_type("Article")
    @tags =  taggings.collect { |tagging| tagging.tag }.uniq
    @unpublished_articles = Article.find(:all, :conditions => "published = 0 and archived = 0", :order => "created_at DESC")
  end

  def list
    @articles = if @tag_name = params[:id]
      Tag.find_by_name(@tag_name).tagged.collect {|tagged| tagged if tagged.class == Article }.compact
    else
      Article.find(:all, :order => "created_at DESC")
    end
  end

  def tag
    @article = Article.find(params[:id])
    @article.tag_with(params[:tag_list])
    @article.save
    @tags_list = Tagging.find(:all).collect { |tagging| tagging.tag }.uniq
    render :partial => "admin/shared/tags", :locals => { :tagged => @article }
  end

  def show
    @article = Article.find_by_permalink(params[:id])
    @images = @article.images.find(:all)
    @attachments = @article.attachments
    @tags_list = Tagging.find(:all).collect { |tagging| tagging.tag }.uniq
  end

  def new
    @categories = Category.find(:all)
    @article = Article.new(params[:article])
    @current_category = params[:category_id].to_i || 0
    if request.post? 
      @current_category = params[:article][:category_id].to_i || params[:category_id].to_i
      if @article.save
        flash[:notice] = "Your article was created."
        redirect_to :action => 'show', :id => @article
      else
        render :action => 'new', :category_id => params[:category_id]
      end
    end
  end

  def edit
    @categories = Category.find(:all)
    @article = Article.find_by_permalink(params[:id])
    @current_category = @article.category.id
    @article.attributes = params[:article]
    @images = @article.images
    @attachments = @article.attachments

    if (@article.published and permit? "cms_admin") or @article.published != true 
      if request.post? 
        if @article.save
          flash[:notice] = 'Article was successfully updated.'
          redirect_to :action => 'show', :id => @article
        else
          @article.reload
        end
      end
    else
      redirect_to :controller => "/account", :action => "denied"
    end
  end

  def upload_image
    @article = Article.find_by_permalink(params[:id])
    if request.post?
      @img = Image.new(params[:img])
      @article.images << @img unless @img.name.nil?
      if @article.save
        flash[:notice] = 'Image was successfully uploaded.'
      end
    end
    redirect_to :action => 'edit', :id => @article
  end

  def delete_image
    unless params[:id].nil?
      image = Image.find(params[:id])
      article = image.article
      if image.destroy
        flash[:notice] = 'Image was successfully deleted.'
        redirect_to :action => 'edit', :id => article
      end
    else
      redirect_to :action => 'index'
    end
  end

  def upload_attachment
    article = Article.find_by_permalink(params[:id])
    if request.post?
      attachment = Attachment.new(params[:attachment])
      article.attachments << attachment unless attachment.file.nil?
      if article.save
        flash[:notice] = 'File was successfully uploaded.'
      end
    end
    redirect_to :action => 'edit', :id => article
  end

  def delete_attachment
    unless params[:id].nil?
      attachment = Attachment.find(params[:id])
      article = attachment.article
      if attachment.destroy
        flash[:notice] = 'File was successfully deleted.'
        redirect_to :action => 'edit', :id => article
      end
    else
      redirect_to :action => 'index'
    end
  end

  def publish
    article = Article.find_by_permalink(params[:id])
    article.published = true
    article.published_at = Time.now if article.published_at.blank?
    article.archived = false
    article.archived_at = 0
    if request.post? and article.save
      flash[:notice] = 'Article was successfully published.'
    end
    redirect_to :action => 'show', :id => article
  end

  def unpublish
    article = Article.find_by_permalink(params[:id])
    article.published = false
    article.published_at = nil
    if request.post? and article.save
      flash[:notice] = 'Article was successfully unpublished.'
    end
    redirect_to :action => 'show', :id => article
  end

  def archive
    article = Article.find_by_permalink(params[:id])
    article.archived = true
    article.published = false
    article.archived_at = Time.now
    if request.post? and article.save
      flash[:notice] = 'Article was successfully archived and unpublished.'
    end
    redirect_to :action => 'show', :id => article
  end
  
  def unarchive
    article = Article.find_by_permalink(params[:id])
    article.archived = false
    article.archived_at = 0
    if request.post? and article.save
      flash[:notice] = 'Article was successfully unarchived.'
    end
    redirect_to :action => 'show', :id => article
  end
  
  def delete
    @article = Article.find_by_permalink(params[:id])
    if request.post?
      @article.destroy
      flash[:notice] = 'Article was successfully deleted.'
      redirect_to :action => 'index'
    else
      redirect_to :action => 'show', :id => @article
    end
  end

  def show_syntax_guide
  end

  def close_syntax_guide
  end
end
