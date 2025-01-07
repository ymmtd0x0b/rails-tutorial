require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test 'password resets' do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'

    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: '' } }
    assert flash.key?(:danger)
    assert_template 'password_resets/new'

    # メールアドレスが有効
    post password_resets_path, params: { password_reset: { email: 'michael@example.com' } }
    assert flash.key?(:info)
    assert_redirected_to root_url

    # パスワード再設定フォームのテスト
    user = assigns(:user)

    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_path

    # 無効なユーザー
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_path
    user.toggle!(:activated)

    # メールアドレスが有効 かつ トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_path

    # メールアドレスとトークンが有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email

    # パスワードどパスワード確認が不一致
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              'foobar',
                            password_confirmation: 'abcdef' } }
    assert_select 'div#error_explanation'

    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              '',
                            password_confirmation: '' } }
    assert_select 'div#error_explanation'

    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              'foobar',
                            password_confirmation: 'foobar' } }
    assert is_logged_in?
    assert flash.key?(:success)
    assert_redirected_to user
  end
end
