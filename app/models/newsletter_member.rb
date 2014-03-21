class NewsletterMember < ActiveRecord::Base
  has_many :newsletter_member_sectors, :dependent => :destroy, :uniq => true
  has_many :sectors, :through => :newsletter_member_sectors, :uniq => true

  validates_presence_of :email
  validates_format_of :email
  validates_uniqueness_of :email, :message => "has already been taken"
  validates_length_of :email, :within => 3..100, :too_short => "is too short", :too_long => "is too long"
  
  def self.get_valid_emails
    emails = self.find(:all).collect{|member| member.email if member.email =~ RFC822::EmailAddress }
    return emails.flatten.compact.uniq
  end

end
