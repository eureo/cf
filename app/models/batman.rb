class Batman < ActionMailer::Base  
  
  def mail_to_member(mailing, recipient)
    @recipients = recipient
    @from = mailing.from
    @subject = mailing.subject
    @body[:message_body] = mailing.body
  end

end
