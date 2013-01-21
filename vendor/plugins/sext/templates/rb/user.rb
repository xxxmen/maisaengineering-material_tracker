require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :first_name, :last_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_uniqueness_of   :login, :case_sensitive => false, :allow_blank => true
  validates_uniqueness_of   :email, :case_sensitive => false, :allow_blank => false
  
  before_save :encrypt_password
  
  def sext_data
  	json = {}
  	json[:id] = self.id
  	json[:first_name] = self.first_name
  	json[:last_name] = self.last_name
  	json[:email] = self.email
  	json[:login] = self.login
  	json[:telephone] = self.telephone
  	json[:fax] = self.fax
  	json[:cell] = self.cell
  	json[:created_at] = self.created_at
  	json[:updated_at] = self.updated_at
  	return json
  end
        
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && (u.crypted_password == self.encrypt(password, u.salt)) ? u : nil
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    time = 2.weeks.from_now.utc
    self.remember_token_expires_at = time
    self.remember_token            = User.encrypt("#{email}--#{remember_token_expires_at}", self.salt)
    save(false)
  end
    
  # Removes user's ability to login w/o entering a username/password
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def full_name
    first_name + " " + last_name
  end
  
  protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = User.encrypt(password, self.salt)
  end
  
  # A password is required if the user has a login AND
  # either it's a new user, in which case the crypted password will be blank
  # 
  # Can be used for either password or password_confirmation  
  def password_required?
    # We checked !password.blank? here to determine if password_confirmation is needed
    !login.blank? && (crypted_password.blank? || !password.blank?)
  end    
end
