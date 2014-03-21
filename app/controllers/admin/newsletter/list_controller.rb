class Admin::Newsletter::ListController < Admin::Newsletter::EmailsController

  before_filter :set_page_title
  access_control :DEFAULT => 'email_admin'
  
  def index
    @lists = Mailinglist.find(:all)
  end
  
  def show
    @list = Mailinglist.find(params[:id])
  end
  
  def new
    @list = Mailinglist.new params[:list]
    return unless request.post?
    if @list.save
      redirect_to :action => "show", :id => @list
    end
  end
  
  def edit
    @list = Mailinglist.find(params[:id])
    return unless request.post?
    @list.update_attributes(params[:list])
    if @list.save
      redirect_to :action => "show", :id => @list
    end
  end
    
  def delete
    Mailinglist.delete(params[:id])
    redirect_to :action => "index"
  end
    
  def import_from_csv
    csv_file = CsvFile.find(params[:csv_file][:file_id])
    
    emails = csv_file.get_emails.uniq
    list = Mailinglist.find(params[:list_id])
    
    emails.each do |email|
      member = MlMember.find_by_email(email) || MlMember.create!(:email => email)
      list.ml_members << member
    end
      
    list.save!
    redirect_to :action => "show", :id => list
  end
  
  def add_members
    @list = Mailinglist.find(params[:list_id])
    @csv_files = CsvFile.find(:all, :order => "filename")
    
    @member = MlMember.new params[:member]
    return unless request.post?
    @member = MlMember.find_by_email(params[:member][:email]) || MlMember.new(params[:member])
    if @member.save
      unless @list.ml_members.find_by_email(@member.email)
        @list.ml_members << @member
        if @list.save!
          flash[:notice] = "Member has beed added"
        end
      else
        flash[:notice] = "Member already in the list"
      end
    end
  end
  
  def create_member
    member = MlMember.new params[:member]
    list = Mailinglist.find(params[:list_id])
    list.ml_members << member
    list.save!
    redirect_to :action => "show", :id => params[:list_id]
  end
  
  protected
  
  def set_page_title
    @page_title = "Emails : " + l("Lists")
  end

end
