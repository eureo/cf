class NewsletterMemberSector < ActiveRecord::Base
  belongs_to :newsletter_member
  belongs_to :sector
end
