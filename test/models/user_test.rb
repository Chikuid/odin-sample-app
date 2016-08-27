require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
  	@user = User.new(name: "Shivam Singh", email: "example@gmail.com",
  					password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "name should be present" do
  	@user.name = "    "
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = "    "
  	assert_not @user.valid?
  end

  test "name should not be longer than 50 letters" do
  	@user.name = 'a' * 51
  	assert_not @user.valid?
  end

  test "email should not be longer than 256 letters" do
  	@user.email = "a" * 244 + "@example.com"
  	assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
  	valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
  						first.last@foo.jp alice+bob@baz.cn]
  	valid_addresses.each do |valid_address|
  		@user.email = valid_address
  		assert @user.valid? , "#{valid_address.inspect} should be valid"
  	end
  end

  test "email validation should reject invalid addresses" do
  	invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
  							foo@bar_baz.com foo@bar+baz.com]
  	invalid_addresses.each do |invalid_address|
  		@user.email = invalid_address
  		assert_not @user.valid?, "#{invalid_address.inspect} should not be valid"
  	end
  end

  test "email addresses should be unique" do
  	duplicate_user = @user.dup
  	duplicate_user.email = duplicate_user.email.upcase
  	@user.save
  	assert_not duplicate_user.valid?
  	end

  test "email addresses should be saved as lowercase" do
  	mixed_case_email = "Foo@EXample.com"
  	@user.email = mixed_case_email
  	@user.save
  	assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!( content: "Lorem Ipsum" )
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    gaara = users(:gaara)
    archer = users(:archer)
    assert_not gaara.following?(archer)
    gaara.follow(archer)
    assert archer.followers.include?(gaara)
    assert gaara.following?(archer)
    gaara.unfollow(archer)
    assert_not gaara.following?(archer)
  end

  test "feed should have the right posts" do
    gaara = users(:gaara)
    archer = users(:archer)
    lana = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert gaara.feed.include?(post_following)
    end
    # Posts from self
    gaara.microposts.each do |post_self|
      assert gaara.feed.include?(post_self)
    end
    # Post from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not gaara.feed.include?(post_unfollowed)
    end
  end
end
