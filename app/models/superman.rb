#class Superman < ActionMailer::ARMailer
class Superman < ActionMailer::Base

  def message(message)
    case message['recipient']
    when 'contact'
      @recipients = []
      @recipients << "olivier@connexion-francaise.com"
      @recipients << "franck.dagostini@gmail.com"
    when 'webmaster'
      @recipients = []
      @recipients << "franck.dagostini@gmail.com"
    when 'caro'
      @recipients = "caroline.belot@connexion-emploi.com"
		when 'thomas'
			@recipients = []
      @recipients << "olivier@connexion-francaise.com"
			@recipients << "thdesray@yahoo.com"
    else
      @recipients = message['recipient']
    end
    @from = "site@connexion-francaise.com"
    @subject = message['subject']
    @body["message"] = message['body']
  end
  
  def inscription_newsletter(message)
    @recipients = []
    @recipients << "olivier.jacquemond@connexion-francaise.com"
    @from = "site@connexion-francaise.com"
    @subject = "[CF] inscription newsletter"
    @body["message"] = message
  end
  
  def confirmation_inscription_newsletter(message)
    @recipients = message['email']
    @from = "site@connexion-francaise.com"
    @subject = "Confirmation inscription à la newsletter"
    @body["message"] = message
  end
  
  def desinscription_newsletter(message)
    @recipients = []
    @recipients << "olivier.jacquemond@connexion-francaise.com"
    @from = "site@connexion-francaise.com"
    @subject = "[CF] désinscription newsletter"
    @body["message"] = message
  end
  
  def confirmation_desinscription_newsletter(message)
    @recipients = message['email']
    @from = "site@connexion-francaise.com"
    @subject = "Confirmation de votre déinscription"
    @body["message"] = message
  end
  
  
end
