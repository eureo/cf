class Reaction < ActiveRecord::Base  
  attr_accessor :answer
  attr_accessor :article
  attr_accessor :subject
  attr_accessor :email
  attr_accessor :content
  
  validates_presence_of :subject, :message => "Vous oubliez de donner un sujet à votre message"
  validates_presence_of :email, :message => "Vous oubliez votre adresse email"
  validates_presence_of :content, :message => "Vous oubliez le contenu du message"
  
  validates_presence_of :answer, :message => "Vous oubliez de répondre à la question anti-spam"
end
