class UserNotifier < ActionMailer::Base
  
  include LocalizationSettings
  
  def signup_notification(user)
    setup_email(user)
    @subject    += "#{l('Please activate your new account')}"
    @body[:url]  = "http://ce.merrycreation.com/account/activate/#{user.activation_code}"
    @body[:url_activate]  = "http://ce.merrycreation.com/account/activate" 
  end
  
  def activation(user)
    setup_email(user)
    @subject    += "#{l('Your account has been activated!')}"
    @body[:url]  = "http://ce.merrycreation.com/admin"
  end

  def forgot_password(user)
    setup_email(user)
    @subject    += "#{l('Request to change your password')}"
    @body[:url]  = "http://ce.merrycreation.com/account/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    setup_email(user)
    @subject    += "#{l('Your password has been reset')}"
  end

  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "Connexion Emploi <admin@connexion-emploi.com>"
    @subject     = "[CE] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
