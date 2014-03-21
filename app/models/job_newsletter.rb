class RegionalNewsletter < ActiveRecord::Base
  has_and_belongs_to_many :sectors
  
  def get_all_valid_emails
    self.sectors.collect{|s| s.newsletter_members.get_valid_emails }.flatten.compact.uniq
  end
  
end
