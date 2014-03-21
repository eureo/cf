module EmailValidator
  
  def self.validate_email(email)
    return false if email.nil? or email.blank?
    email =~ EmailValidator.email_regex
  end
  
  def self.email_regex()
    return @email_regex if @email_regex
    email_name_regex  = '[A-Z0-9_\.%\+\-]+'
    domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
    domain_tld_regex  = '(?:[A-Z]{2,4}|museum|travel)'
    @email_regex = /^#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}$/i
  end
  
end