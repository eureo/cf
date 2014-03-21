require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
 	include AuthenticatedUserTestHelper	
  fixtures :users

  def test_should_create_user
    assert_difference User, :count do
      assert create_user.valid?
    end
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:franck).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:franck), User.authenticate('franck', 'new password')
  end

  def test_should_not_rehash_password
    users(:franck).update_attributes(:login => 'franck2')
    assert_equal users(:franck), User.authenticate('franck2', 'thibamay')
  end

  def test_should_authenticate_user
    assert_equal users(:franck), User.authenticate('franck', 'thibamay')
  end

  protected
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end
