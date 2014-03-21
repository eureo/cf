class Mailinglist < ActiveRecord::Base
  has_and_belongs_to_many :ml_members, :uniq => true
  validates_presence_of :name
end

