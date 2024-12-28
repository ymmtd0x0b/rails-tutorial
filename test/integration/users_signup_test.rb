require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '',
                                          email: 'user@invalid',
                                          password: 'foo',
                                          password_confirmation: 'bar'} }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation' do
      assert_select 'div', text: 'The form contains 4 errors'
      assert_select 'li', text: "Name can't be blank"
      assert_select 'li', text: 'Email is invalid'
      assert_select 'li', text: "Password confirmation doesn't match Password"
      assert_select 'li', text: 'Password is too short (minimum is 6 characters)'
    end
  end

  test 'valid signup information with account activation' do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Example User',
                                         email: 'user@example.com',
                                         password:              'password',
                                         password_confirmation: 'password' } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user) # 対応するアクション内のインスタンス変数を取得
    assert_not user.activated?

    # 有効化していない状態でのログイン検証
    log_in_as(user)
    assert_not is_logged_in?

    # 不正な有効化トークンによるアクティベーションの検証
    get edit_account_activation_path('invalid token', email: user.email)
    assert_not is_logged_in?

    # 有効なトークンによるアクティベーションの検証
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
