require 'faster_csv'

class Admin::Newsletter::ImportController < Admin::Newsletter::EmailsController

  before_filter :set_page_title
  access_control :DEFAULT => 'email_admin'

  def index
    @csv_files = CsvFile.find(:all)
  end
  
  def new
    @csv_file = CsvFile.new
  end
  
  def show
    @csv_file = CsvFile.find(params[:id])
    emails = @csv_file.get_emails
    
    @emails_size_before_uniq = emails.size
    @emails = emails.uniq
  end

  def create
    return unless request.post?
    @csv_file = CsvFile.create! params[:csv_file]
    redirect_to :action => "show", :id => @csv_file
  rescue ActiveRecord::RecordInvalid
    render :action => "new"
  end
  
  def delete
    CsvFile.delete(params[:id])
    redirect_to :action => "index"
  end
  
  def import_to_newsletter
    @csv_files = CsvFile.find(:all)
    @sectors = Sector.find(:all)
    
    return unless request.post?
    
    csv_file = CsvFile.find(params[:csv_files][:file_id])
    sector = Sector.find(params[:sectors][:sector_id])
    emails = csv_file.get_emails.uniq
    
    for email in emails
      newsletter_member = NewsletterMember.find_by_email(email) || NewsletterMember.new(:email => email)
      NewsletterMemberSector.create( 
        :newsletter_member => newsletter_member,
        :sector => sector)
    end
    
    flash[:notice] = "#{emails.size} emails has been imported to newsletter #{sector.name}"
    
  end
  
  protected
  
  def set_page_title
    @page_title = "Emails : " + l("Import CSV Files")
  end

end
