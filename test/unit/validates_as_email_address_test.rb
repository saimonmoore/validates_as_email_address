require File.dirname(__FILE__) + '/../test_helper'

class ValidatesAsEmailAddressByDefaultTest < Test::Unit::TestCase
  def setup
    User.validates_as_email_address :email
  end
  
  def test_should_not_allow_email_addresses_shorter_than_3_characters
    user = new_user(:email => 'a@')
    assert !user.valid?
    assert_equal 2, Array(user.errors.on(:email)).size
  end
  
  def test_should_not_allow_email_addresses_longer_than_320_characters
    user = new_user(:email => 'a@' + 'a' * 315 + '.com')
    assert !user.valid?
    assert_equal 1, Array(user.errors.on(:email)).size
  end
  
  def test_should_allow_legal_rfc822_formats
    [
      'test@example',
      'test@example.com', 
      'test@example.co.uk',
      '"J. Smith\'s House, a.k.a. Home!"@example.com',
      'test@123.com',
    ].each do |address|
      user = new_user(:email => address)
      assert user.valid?, "#{address} should be legal."
    end
  end
  
  def test_should_not_allow_illegal_rfc822_formats
    [
      'test@Monday 1:00', 
      'test@Monday the first',
      'J. Smith\'s House, a.k.a. Home!@example.com',
    ].each do |address|
      user = new_user(:email => address)
      assert !user.valid?, "#{address} should be illegal."
      assert_equal 1, Array(user.errors.on(:email)).size
    end
  end
  
  def test_should_not_allow_illegal_rfc1035_formats
    [
      'test@[127.0.0.1]',
      'test@-domain_not_starting_with_letter.com',
      'test@domain_not_ending_with_alphanum-.com'
    ].each do |address|
      user = new_user(:email => address)
      assert !user.valid?, "#{address} should be illegal."
    end
  end
  
  def teardown
    User.class_eval do
      @validate_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_create_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_update_callbacks = ActiveSupport::Callbacks::CallbackChain.new
    end
  end
end

class ValidatesAsEmailAddressTest < Test::Unit::TestCase
  def test_should_allow_minimum_length
    User.validates_as_email_address :email, :minimum => 8
    
    user = new_user(:email => 'a@aa.com')
    assert user.valid?
    
    user = new_user(:email => 'a@a.com')
    assert !user.valid?
  end
  
  def test_should_not_check_maximum_length_if_minimum_length_defined
    User.validates_as_email_address :email, :minimum => 10
    
    user = new_user(:email => 'a@' + 'a' * 315 + '.com')
    assert user.valid?
  end
  
  def test_should_allow_maximum_length
    User.validates_as_email_address :email, :maximum => 8
    
    user = new_user(:email => 'a@aa.com')
    assert user.valid?
    
    user = new_user(:email => 'a@aaa.com')
    assert !user.valid?
  end
  
  def test_should_not_check_minimum_length_if_maximum_length_defined
    User.validates_as_email_address :email, :maximum => 8
    
    user = new_user(:email => 'a@a')
    assert !user.valid?
    assert_equal 1, Array(user.errors.on(:email)).size
  end
  
  def test_should_allow_exact_length
    User.validates_as_email_address :email, :is => 8
    
    user = new_user(:email => 'a@aa.com')
    assert user.valid?
    
    user = new_user(:email => 'a@a.com')
    assert !user.valid?
    
    user = new_user(:email => 'a@aaa.com')
    assert !user.valid?
  end
  
  def test_should_allow_within_range
    User.validates_as_email_address :email, :within => 8..10
    
    user = new_user(:email => 'a@a.com')
    assert !user.valid?
    
    user = new_user(:email => 'a@aa.com')
    assert user.valid?
    
    user = new_user(:email => 'a@aaaa.com')
    assert user.valid?
    
    user = new_user(:email => 'a@aaaaa.com')
    assert !user.valid?
  end
  
  def test_should_allow_in_range
    User.validates_as_email_address :email, :in => 8..10
    
    user = new_user(:email => 'a@a.com')
    assert !user.valid?
    
    user = new_user(:email => 'a@aa.com')
    assert user.valid?
    
    user = new_user(:email => 'a@aaaa.com')
    assert user.valid?
    
    user = new_user(:email => 'a@aaaaa.com')
    assert !user.valid?
  end
  
  def test_should_allow_too_long_message
    User.validates_as_email_address :email, :too_long => 'custom'
    
    user = new_user(:email => 'a@' + 'a' * 315 + '.com')
    user.valid?
    
    assert_equal 'custom', Array(user.errors.on(:email)).last
  end
  
  def test_should_allow_too_short_message
    User.validates_as_email_address :email, :too_short => 'custom'
    
    user = new_user(:email => 'a@')
    user.valid?
    
    assert_equal 'custom', Array(user.errors.on(:email)).last
  end
  
  def test_should_allow_wrong_length_message
    User.validates_as_email_address :email, :is => 8, :wrong_length => 'custom'
    
    user = new_user(:email => 'a@a.com')
    user.valid?
    
    assert_equal 'custom', Array(user.errors.on(:email)).last
  end
  
  def test_should_allow_wrong_format_message
    User.validates_as_email_address :email, :is => 8, :wrong_format => 'custom'
    
    user = new_user(:email => 'a@a')
    user.valid?
    
    assert_equal 'custom', Array(user.errors.on(:email)).first
  end
  
  def test_should_validate_if_if_is_true
    User.validates_as_email_address :email, :if => lambda {true}
    
    user = new_user(:email => 'a')
    assert !user.valid?
  end
  
  def test_should_not_validate_if_if_is_false
    User.validates_as_email_address :email, :if => lambda {false}
    
    user = new_user(:email => 'a')
    assert user.valid?
  end
  
  def test_should_validate_if_unless_is_false
    User.validates_as_email_address :email, :unless => lambda {false}
    
    user = new_user(:email => 'a')
    assert !user.valid?
  end
  
  def test_should_not_validate_if_unless_is_true
    User.validates_as_email_address :email, :unless => lambda {true}
    
    user = new_user(:email => 'a')
    assert user.valid?
  end
  
  def teardown
    User.class_eval do
      @validate_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_create_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_update_callbacks = ActiveSupport::Callbacks::CallbackChain.new
    end
  end
end

class ValidatesAsEmailAddressUnrestrictedTest < Test::Unit::TestCase
  def setup
    User.validates_as_email_address :email, :strict => false
  end
  
  def test_should_allow_illegal_rfc1035_formats
    [
      'test@[127.0.0.1]',
      'test@-domain_not_starting_with_letter.com',
      'test@domain_not_ending_with_alphanum-.com'
    ].each do |address|
      user = new_user(:email => address)
      assert user.valid?, "#{address} should be legal."
    end
  end
end
