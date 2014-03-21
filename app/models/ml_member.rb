class MlMember < ActiveRecord::Base
  has_and_belongs_to_many :mailinglists, :uniq => true
  validates_presence_of :email
  validates_uniqueness_of :email
end
