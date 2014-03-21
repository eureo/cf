class Contact < ActionMailer::ARMailer

  def contact_email(info)
    case info['recipient']
    when 'contact'
      @recipients = "olivier.jacquemond@connexion-francaise.com, franck.dagostini@gmail.com"
    when 'webmaster'
      @recipients = "webmaster@connexion-emploi.com"
    end
    @from = "site@connexion-emploi.com"
    @subject = '[CE]' + "[#{info['recipient']}] " + info['subject']
    @body["message"] = info['message']
    @body['sender_contact'] = info['sender_contact']
  end
  
end
