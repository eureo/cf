require 'digest/sha1'
class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  # edition mode 
  attr_accessor :edition_mode
  
  # for activation
  before_create :make_activation_code

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?, :too_short => "is too short", :too_long => "is too long"  
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40, :too_short => "is too short", :too_long => "is too long"
  validates_length_of       :email,    :within => 3..100, :too_short => "is too short", :too_long => "is too long"
  validates_uniqueness_of   :login, :email
  before_save :encrypt_password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    
    # for activation
    #u = find_by_login(login) # need to get the salt
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]

    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_me
    if self.remember_token.nil?
      update_attributes(:remember_token => Digest::SHA1.hexdigest("#{salt}--#{self.email}--#{Time.now}"))
    end
  end

  def forget_me
    update_attributes(:remember_token => nil)
  end
  
  # for activation  
  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end

  # for activation  
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
    @reset_password = true
  end

  def recently_reset_password?
    @reset_password
  end

  def recently_forgot_password?
    @forgotten_password
  end


  protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    (crypted_password.blank? or not password.blank?) or edition_mode
  end

  # If you're going to use activation, uncomment this too
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end


end
