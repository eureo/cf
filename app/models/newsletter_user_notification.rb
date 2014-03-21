class NewsletterUserNotification < ActionMailer::ARMailer

  def on_signin(message)
    @recipients = message['email']
    @from = "site@connexion-emploi.com"
    @subject = '[CE] Confirmation Abonnement Emploi' 
    @body['email'] = message['email']
    @body['sectors_fr'] = message['sectors_fr']
    @body['sectors_de'] = message['sectors_de']
  end
  
  def on_signout(member)
    @recipients = member
    @from = "site@connexion-emploi.com"
    @subject = '[CE] Confirmation Désabonnement Emploi'
    @body['email'] = member
  end

end
