class Admin::Newsletter::NewsletterController < Admin::Newsletter::EmailsController
  
  before_filter :set_page_title
  access_control :DEFAULT => 'email'

  def index
    @mailings = Mailing.find(:all)
  end

  def show
    @mailing = Mailing.find(params[:id])
  end

  def new
    @mailing = Mailing.new params[:mailing]
    return unless request.post?
    if @mailing.save
      redirect_to :action => "index"
    end
  end
  
  def edit
    @mailing = Mailing.find(params[:id])
    return unless request.post?
    @mailing.update_attributes(params[:mailing])
    if @mailing.save
      redirect_to :action => "index"
    end
  end
    
  def delete
    Mailing.destroy params[:id]
    redirect_to :action => "index"
  end

  def send_mailing
    mailing = Mailing.find params[:id]
    
    @recipients = mailing.to.split(', ')
    @recipients << "olivier.jacquemond@connexion-francaise.com"
    for recipient in @recipients
      Batman.deliver_mail_to_member(mailing, recipient)
    end

    flash[:notice] = "Mailing has been send"
    redirect_to :action => "index"
  end
  
  def test_mailing
    mailing = Mailing.find params[:id]
    
    email = current_user.email
    Batman.deliver_mail_to_member(mailing, email)

    flash[:notice] = "Mailing has been send to #{email}"
    redirect_to :action => "index"
  end


  protected
  
  def set_page_title
    @page_title = "Emails : Mailing"
  end	

end
